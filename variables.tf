variable "github_organization" {
  type        = string
  description = "The GitHub organization name"
}

variable "repository_collaborators" {
  type = map(list(object({
    username                    = string
    permission                  = optional(string, "push")
    permission_diff_suppression = optional(bool, false)
  })))
  description = "Map of repositories to their list of collaborators. Key format: owner/repository"
  default     = {}

  validation {
    condition = alltrue(flatten([
      for repo, collaborators in var.repository_collaborators : [
        for collab in collaborators :
        contains(["pull", "triage", "push", "maintain", "admin"], coalesce(collab.permission, "push"))
      ]
    ]))
    error_message = "Permission must be one of: pull, triage, push, maintain, admin."
  }

  validation {
    condition = alltrue([
      for repo_name in keys(var.repository_collaborators) :
      can(regex("^[^/]+/[^/]+$", repo_name))
    ])
    error_message = "Repository name must be in the format 'owner/repository'."
  }
}

variable "teams" {
  type = map(object({
    name                      = string
    description               = optional(string)
    privacy                   = optional(string, "secret")
    parent_team_id            = optional(number)
    ldap_dn                   = optional(string)
    create_default_maintainer = optional(bool, false)
    members = optional(list(object({
      username = string
      role     = optional(string, "member")
    })), [])
    review_request_delegation = optional(object({
      algorithm    = optional(string, "ROUND_ROBIN")
      member_count = optional(number, 1)
      notify       = optional(bool, true)
    }))
  }))
  description = "Map of teams to manage"
  default     = {}

  validation {
    condition = alltrue([
      for team in values(var.teams) :
      contains(["secret", "closed"], coalesce(team.privacy, "secret"))
    ])
    error_message = "Privacy must be either 'secret' or 'closed'."
  }

  validation {
    condition = alltrue(flatten([
      for team in values(var.teams) : [
        for member in team.members :
        contains(["member", "maintainer"], coalesce(member.role, "member"))
      ]
    ]))
    error_message = "Member roles must be either 'member' or 'maintainer'."
  }

  validation {
    condition = alltrue([
      for team in values(var.teams) :
      team.review_request_delegation == null ? true : (
        contains(["ROUND_ROBIN", "LOAD_BALANCE"], team.review_request_delegation.algorithm != null ? team.review_request_delegation.algorithm : "ROUND_ROBIN")
      )
    ])
    error_message = "Review request delegation algorithm must be either 'ROUND_ROBIN' or 'LOAD_BALANCE'."
  }

  validation {
    condition = alltrue([
      for team in values(var.teams) :
      team.review_request_delegation == null ? true : (
        (team.review_request_delegation.member_count != null ? team.review_request_delegation.member_count : 1) >= 1
      )
    ])
    error_message = "Review request delegation member_count must be at least 1."
  }

  validation {
    condition = alltrue([
      for team_key, team in var.teams :
      lower(replace(replace(team.name, " ", "-"), "/[^a-zA-Z0-9-]/", "")) == team_key
    ])
    error_message = "Team map key must match the slugified team name (lowercase, spaces replaced with hyphens, special characters removed)."
  }
}
