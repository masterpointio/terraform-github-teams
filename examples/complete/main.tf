module "github_teams" {
  source = "../../"

  github_organization = "example-org"

  organization_memberships = [
    {
      username             = "lead-engineer"
      role                 = "admin"
      downgrade_on_destroy = true
    },
    {
      username = "senior-engineer"
      role     = "admin"
    },
    {
      username = "junior-engineer"
    },
    {
      username = "external-contributor"
      role     = "member"
    }
  ]

  teams = {
    "platform-engineers" = {
      name        = "Platform Engineers"
      description = "Team responsible for platform infrastructure"
      privacy     = "secret"
      members = [
        {
          username = "lead-engineer"
          role     = "maintainer"
        },
        {
          username = "senior-engineer"
          role     = "member"
        },
        {
          username = "junior-engineer"
          role     = "member"
        }
      ]
      review_request_delegation = {
        algorithm    = "ROUND_ROBIN"
        member_count = 2
        notify       = true
      }
    }
  }

  repository_collaborators = {
    "example-org/repo1" = [
      {
        username   = "external-contributor"
        permission = "maintain"
      }
    ]
  }
}
