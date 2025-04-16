mock_provider "github" {
  alias = "mock"
}

variables {
  github_organization = "example-org"
  teams = {
    "developers" = {
      name = "Developers"
      members = [
        {
          username = "rachel"
          role     = "maintainer"
        },
        {
          username = "monica"
          role     = "maintainer"
        },
        {
          username = "ross"
          role     = "member"
        }
      ]
    },
    "platform-engineers" = {
      name    = "Platform Engineers"
      privacy = "closed"
      members = [
        {
          username = "chandler"
          role     = "maintainer"
        }
      ]
    }
  }
  repository_collaborators = {
    "example-org/repo1" = [
      {
        username   = "monica"
        permission = "admin"
      },
      {
        username   = "joey"
        permission = "push"
      }
    ],
    "example-org/repo2" = [
      {
        username   = "phoebe"
        permission = "maintain"
      }
    ]
  }
}

run "validate_developers_team" {
  command = plan

  providers = {
    github = github.mock
  }

  assert {
    condition     = github_team.default["developers"].name == "Developers"
    error_message = "Developers team should have correct name"
  }

  assert {
    condition     = github_team.default["developers"].privacy == "secret"
    error_message = "Developers team should have default privacy setting (secret)"
  }
}

run "validate_platform_engineers_team" {
  command = plan

  providers = {
    github = github.mock
  }

  assert {
    condition     = github_team.default["platform-engineers"].name == "Platform Engineers"
    error_message = "Platform Engineers team should have correct name"
  }

  assert {
    condition     = github_team.default["platform-engineers"].privacy == "closed"
    error_message = "Platform Engineers team should have overridden privacy setting (closed)"
  }
}

run "validate_team_memberships" {
  command = plan

  providers = {
    github = github.mock
  }

  assert {
    condition     = github_team_membership.default["developers:rachel"].role == "maintainer"
    error_message = "Rachel should be a maintainer in the developers team"
  }

  assert {
    condition     = github_team_membership.default["developers:ross"].role == "member"
    error_message = "Ross should be a member in the developers team"
  }

  assert {
    condition     = github_team_membership.default["platform-engineers:chandler"].role == "maintainer"
    error_message = "Chandler should be a maintainer in the platform-engineers team"
  }
}

run "validate_repository_collaborators" {
  command = plan

  providers = {
    github = github.mock
  }

  assert {
    condition     = github_repository_collaborator.default["example-org/repo1:monica"].permission == "admin"
    error_message = "Monica should have admin permission on repo1"
  }

  assert {
    condition     = github_repository_collaborator.default["example-org/repo1:joey"].permission == "push"
    error_message = "Joey should have push permission on repo1"
  }

  assert {
    condition     = github_repository_collaborator.default["example-org/repo2:phoebe"].permission == "maintain"
    error_message = "Phoebe should have maintain permission on repo2"
  }
}

run "validate_outputs" {
  command = plan

  providers = {
    github = github.mock
  }

  # Test team outputs
  assert {
    condition     = output.teams["developers"].name == "Developers"
    error_message = "Team output should contain correct name"
  }

  assert {
    condition     = output.teams["platform-engineers"].privacy == "closed"
    error_message = "Team output should contain correct privacy setting"
  }

  # Test team membership outputs
  assert {
    condition     = output.team_memberships["developers:rachel"].role == "maintainer"
    error_message = "Team membership output should contain correct role"
  }

  assert {
    condition     = output.team_memberships["developers:ross"].role == "member"
    error_message = "Team membership output should contain correct role"
  }

  # Test repository collaborator outputs
  assert {
    condition     = output.repository_collaborators["example-org/repo1:monica"].permission == "admin"
    error_message = "Repository collaborator output should contain correct permission"
  }

  assert {
    condition     = output.repository_collaborators["example-org/repo2:phoebe"].permission == "maintain"
    error_message = "Repository collaborator output should contain correct permission"
  }
}
