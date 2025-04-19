output "teams" {
  description = "Map of team names to their properties including ID and slug"
  value = {
    for name, team in github_team.default : name => {
      id      = team.id
      slug    = team.slug
      name    = team.name
      privacy = team.privacy
    }
  }
}

output "team_memberships" {
  description = "Map of team memberships in format 'team:username' with their roles"
  value = {
    for key, membership in github_team_membership.default : key => {
      team_id  = membership.team_id
      username = membership.username
      role     = membership.role
    }
  }
}

output "repository_collaborators" {
  description = "Map of repository collaborators in format 'repo:username' with their permissions"
  value = {
    for key, collab in github_repository_collaborator.default : key => {
      repository = collab.repository
      username   = collab.username
      permission = collab.permission
    }
  }
}

output "team_settings" {
  description = "Map of team settings for teams with review request delegation configured"
  value = {
    for name, settings in github_team_settings.default : name => {
      team_id = settings.team_id
      review_request_delegation = {
        algorithm    = settings.review_request_delegation[0].algorithm
        member_count = settings.review_request_delegation[0].member_count
        notify       = settings.review_request_delegation[0].notify
      }
    }
  }
}

output "organization_memberships" {
  description = "Map of organization members and their roles"
  value = {
    for membership in github_membership.default : membership.username => membership.role
  }
}
