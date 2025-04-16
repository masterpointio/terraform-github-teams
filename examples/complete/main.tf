module "github_teams" {
  source  = "masterpointio/teams/github"
  version = "0.1.0"

  github_organization = "example-org"

  teams = {
    "platform-engineers" = {
      name        = "Platform Engineers"
      description = "Team responsible for platform infrastructure"
      privacy     = "closed"
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
