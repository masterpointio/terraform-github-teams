mock_provider "github" {
  alias = "mock"
}

variables {
  github_organization = "example-org"

  organization_memberships = [
    {
      username             = "rachel"
      role                 = "admin"
      downgrade_on_destroy = true
    },
    {
      username = "monica"
      role     = "admin"
    },
    {
      username = "ross"
      role     = "member"
    },
    {
      username             = "chandler"
      role                 = "member"
      downgrade_on_destroy = false
    },
    {
      username = "joey"
      role     = "member"
    },
    {
      username = "phoebe"
      role     = "member"
    }
  ]

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

run "validate_organization_memberships" {
  command = plan

  providers = {
    github = github.mock
  }

  assert {
    condition = alltrue([
      github_membership.default["rachel"].role == "admin",
      github_membership.default["monica"].role == "admin",
      github_membership.default["ross"].role == "member",
      github_membership.default["chandler"].role == "member",
      github_membership.default["joey"].role == "member",
      github_membership.default["phoebe"].role == "member"
    ])
    error_message = "Organization members should have correct roles assigned"
  }
}

run "validate_organization_downgrade_behavior" {
  command = plan

  providers = {
    github = github.mock
  }

  assert {
    condition = alltrue([
      github_membership.default["rachel"].downgrade_on_destroy == true,
      github_membership.default["chandler"].downgrade_on_destroy == false,
      github_membership.default["monica"].downgrade_on_destroy == false, # default value
      github_membership.default["ross"].downgrade_on_destroy == false    # default value
    ])
    error_message = "Organization members should have correct downgrade_on_destroy settings"
  }
}

run "validate_all_team_members_in_org" {
  command = plan

  providers = {
    github = github.mock
  }

  assert {
    condition = alltrue([
      for team in var.teams : alltrue([
        for member in team.members :
        contains([for org_member in var.organization_memberships : org_member.username], member.username)
      ])
    ])
    error_message = "All team members must have corresponding organization memberships"
  }
}
