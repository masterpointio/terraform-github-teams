locals {
  memberships_map = merge([
    for team_name, team in var.teams : {
      for member in team.members : "${team_name}:${member.username}" => {
        team_id  = github_team.default[team_name].id
        username = member.username
        role     = member.role
      }
    }
  ]...)

  teams_with_delegation = {
    for team_name, team in var.teams :
    team_name => team
    if team.review_request_delegation != null
  }

  repository_collaborators = merge([
    for repo_name, collaborators in var.repository_collaborators : {
      for collab in collaborators : "${repo_name}:${collab.username}" => {
        repository                  = repo_name
        username                    = collab.username
        permission                  = collab.permission
        permission_diff_suppression = collab.permission_diff_suppression
      }
    }
  ]...)
}

resource "github_team" "default" {
  for_each = var.teams

  name                      = each.value.name
  description               = each.value.description
  privacy                   = each.value.privacy
  parent_team_id            = each.value.parent_team_id
  ldap_dn                   = each.value.ldap_dn
  create_default_maintainer = each.value.create_default_maintainer
}

resource "github_team_membership" "default" {
  for_each = local.memberships_map

  team_id  = each.value.team_id
  username = each.value.username
  role     = each.value.role
}

resource "github_repository_collaborator" "default" {
  for_each = local.repository_collaborators

  repository                  = each.value.repository
  username                    = each.value.username
  permission                  = each.value.permission
  permission_diff_suppression = each.value.permission_diff_suppression
}

resource "github_user_invitation_accepter" "default" {
  for_each = local.repository_collaborators

  invitation_id = github_repository_collaborator.default[each.key].invitation_id
}

resource "github_team_settings" "default" {
  for_each = local.teams_with_delegation

  team_id = github_team.default[each.key].id
  review_request_delegation {
    algorithm    = each.value.review_request_delegation.algorithm
    member_count = each.value.review_request_delegation.member_count
    notify       = each.value.review_request_delegation.notify
  }
}
