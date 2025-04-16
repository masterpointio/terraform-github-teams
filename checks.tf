locals {
  # Create a set of organization owners from organization users
  org_owners = toset([
    for user in data.github_organization.current.users :
    user.login if user.role == "admin"
  ])

  # Create a list of invalid memberships for error message
  invalid_memberships = [
    for key, membership in local.memberships_map :
    {
      username = membership.username
      team     = split(":", key)[0]
    }
    if contains(local.org_owners, membership.username) && membership.role != "maintainer"
  ]
}

data "github_organization" "current" {
  name = var.github_organization
}

check "github_team_org_owners_role" {
  assert {
    condition = alltrue([
      for membership in local.memberships_map :
      !contains(local.org_owners, membership.username) || membership.role == "maintainer"
    ])
    error_message = join("\n",
      concat(
        ["Organization owners must be set as 'maintainer' in teams. Found owners with 'member' role:"],
        [
          for invalid in local.invalid_memberships :
          "  - Username: ${invalid.username}, Team: ${invalid.team}"
        ]
      )
    )
  }
}
