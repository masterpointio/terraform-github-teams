# Note: This test file uses OpenTofu-specific test syntax.
# It is not compatible with Terraform due to differences in the testing framework.
# Key differences:
# - OpenTofu does not support source in mock_provider
# - OpenTofu only allows overriding computed fields
# - OpenTofu has different mock data handling

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
