[![Banner][banner-image]](https://masterpoint.io/)

# terraform-github-teams

[![Release][release-badge]][latest-release]

💡 Learn more about Masterpoint [below](#who-we-are-𐦂𖨆𐀪𖠋).

## Purpose and Functionality

Terraform module for declaratively managing GitHub teams and their related settings within your organization. It enables you to:

- Manage GitHub teams and their configurations
- Control team memberships and roles
- Configure repository collaborators
- Manage organization membership
- Review request delegation settings
- Control team privacy

## Organization Memberships Management

### Enabling/Disabling Management

The module provides flexibility in managing organization memberships through the `organization_memberships_enabled` variable:

- When `true` (default):

  - Terraform creates GitHub organization memberships for all users listed in `organization_memberships`
  - Manages role assignments (admin/member)
  - Handles the `downgrade_on_destroy` behavior per member: when organization membership resource is destroyed, the member will not be removed from the organization. Instead, the member's role will be downgraded to `member`.

- When `false`:
  - No GitHub organization memberships are managed by Terraform
  - Team memberships and other resources continue to be managed

## Usage

### Prerequisites

1. A GitHub organization.
2. Organization admin access.
3. GitHub provider configuration with appropriate permissions.

### Example

```hcl
module "github_teams" {
  source  = "masterpointio/teams/github"
  version = "X.X.X"

  github_organization = "example-org"

  organization_memberships = [
    {
      username = "user1"
      role     = "admin"
    },
    {
      username = "user2"
      role     = "member"
    },
    {
      username = "user3"
      role     = "member"
    }
  ]
  teams = {
    "developers" = {
      name        = "Developers"
      description = "Development team"
      privacy     = "closed"
      members = [
        {
          username = "user1"
          role     = "maintainer"
        },
        {
          username = "user2"
          role     = "member"
        }
      ],
      review_request_delegation = {
        algorithm    = "ROUND_ROBIN"
        member_count = 2
        notify       = true
      }
    },
    "platform-engineers" = {
      name        = "Platform Engineers"
      description = "Platform engineering team"
      members = [
        {
          username = "user3"
          role     = "member"
        }
      ]
    }
  }

  repository_collaborators = {
    "example-org/repo1" = [
      {
        username   = "user3"
        permission = "push"
      }
    ]
  }
}
```

### Validation Rules

The module enforces several validations:

- All team members must be listed in `organization_memberships`
- Valid roles (admin/member) for organization members
- Valid team member roles (maintainer/member)
- Team name slugification rules
- Repository collaborator permissions

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7 |
| <a name="requirement_github"></a> [github](#requirement\_github) | >= 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_github"></a> [github](#provider\_github) | >= 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [github_membership.default](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/membership) | resource |
| [github_repository_collaborator.default](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_collaborator) | resource |
| [github_team.default](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team) | resource |
| [github_team_membership.default](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_membership) | resource |
| [github_team_settings.default](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_settings) | resource |
| [github_user_invitation_accepter.default](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/user_invitation_accepter) | resource |
| [github_organization.current](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/organization) | data source |
| [github_users.all_users](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/users) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_github_organization"></a> [github\_organization](#input\_github\_organization) | The GitHub organization name | `string` | n/a | yes |
| <a name="input_organization_memberships"></a> [organization\_memberships](#input\_organization\_memberships) | List of organization members. Each member can be configured with a role ('admin' or 'member') and downgrade behavior. | <pre>list(object({<br/>    username             = string<br/>    role                 = optional(string, "member")<br/>    downgrade_on_destroy = optional(bool, false)<br/>  }))</pre> | `[]` | no |
| <a name="input_organization_memberships_enabled"></a> [organization\_memberships\_enabled](#input\_organization\_memberships\_enabled) | Whether to manage organization memberships with Terraform. If false, organization memberships must be managed outside of Terraform. | `bool` | `true` | no |
| <a name="input_repository_collaborators"></a> [repository\_collaborators](#input\_repository\_collaborators) | Map of repositories to their list of collaborators. Key format: owner/repository | <pre>map(list(object({<br/>    username                    = string<br/>    permission                  = optional(string, "push")<br/>    permission_diff_suppression = optional(bool, false)<br/>  })))</pre> | `{}` | no |
| <a name="input_teams"></a> [teams](#input\_teams) | Map of teams to manage | <pre>map(object({<br/>    name                      = string<br/>    description               = optional(string)<br/>    privacy                   = optional(string, "secret")<br/>    parent_team_id            = optional(number)<br/>    ldap_dn                   = optional(string)<br/>    create_default_maintainer = optional(bool, false)<br/>    members = optional(list(object({<br/>      username = string<br/>      role     = optional(string, "member")<br/>    })), [])<br/>    review_request_delegation = optional(object({<br/>      algorithm    = optional(string, "ROUND_ROBIN")<br/>      member_count = optional(number, 1)<br/>      notify       = optional(bool, true)<br/>    }))<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_organization_memberships"></a> [organization\_memberships](#output\_organization\_memberships) | Map of organization members and their roles |
| <a name="output_repository_collaborators"></a> [repository\_collaborators](#output\_repository\_collaborators) | Map of repository collaborators in format 'repo:username' with their permissions |
| <a name="output_team_memberships"></a> [team\_memberships](#output\_team\_memberships) | Map of team memberships in format 'team:username' with their roles |
| <a name="output_team_settings"></a> [team\_settings](#output\_team\_settings) | Map of team settings for teams with review request delegation configured |
| <a name="output_teams"></a> [teams](#output\_teams) | Map of team names to their properties including ID and slug |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Built By

Powered by the [Masterpoint team](https://masterpoint.io/who-we-are/) and driven forward by contributions from the community ❤️

[![Contributors][contributors-image]][contributors-url]

## Contribution Guidelines

Contributions are welcome and appreciated!

Found an issue or want to request a feature? [Open an issue][issues-url]

Want to fix a bug you found or add some functionality? Fork, clone, commit, push, and PR — we'll check it out.

## Who We Are 𐦂𖨆𐀪𖠋

Established in 2016, Masterpoint is a team of experienced software and platform engineers specializing in Infrastructure as Code (IaC). We provide expert guidance to organizations of all sizes, helping them leverage the latest IaC practices to accelerate their engineering teams.

### Our Mission

Our mission is to simplify cloud infrastructure so developers can innovate faster, safer, and with greater confidence. By open-sourcing tools and modules that we use internally, we aim to contribute back to the community, promoting consistency, quality, and security.

### Our Commitments

- 🌟 **Open Source**: We live and breathe open source, contributing to and maintaining hundreds of projects across multiple organizations.
- 🌎 **1% for the Planet**: Demonstrating our commitment to environmental sustainability, we are proud members of [1% for the Planet](https://www.onepercentfortheplanet.org), pledging to donate 1% of our annual sales to environmental nonprofits.
- 🇺🇦 **1% Towards Ukraine**: With team members and friends affected by the ongoing [Russo-Ukrainian war](https://en.wikipedia.org/wiki/Russo-Ukrainian_War), we donate 1% of our annual revenue to invasion relief efforts, supporting organizations providing aid to those in need. [Here's how you can help Ukraine with just a few clicks](https://masterpoint.io/updates/supporting-ukraine/).

## Connect With Us

We're active members of the community and are always publishing content, giving talks, and sharing our hard earned expertise. Here are a few ways you can see what we're up to:

[![LinkedIn][linkedin-badge]][linkedin-url] [![Newsletter][newsletter-badge]][newsletter-url] [![Blog][blog-badge]][blog-url] [![YouTube][youtube-badge]][youtube-url]

... and be sure to connect with our founder, [Matt Gowie](https://www.linkedin.com/in/gowiem/).

## License

[Apache License, Version 2.0][license-url].

[![Open Source Initiative][osi-image]][license-url]

Copyright © 2016-2025 [Masterpoint Consulting LLC](https://masterpoint.io/)

<!-- MARKDOWN LINKS & IMAGES -->

[banner-image]: https://masterpoint-public.s3.us-west-2.amazonaws.com/v2/standard-long-fullcolor.png
[license-url]: https://opensource.org/license/apache-2-0
[osi-image]: https://i0.wp.com/opensource.org/wp-content/uploads/2023/03/cropped-OSI-horizontal-large.png?fit=250%2C229&ssl=1
[linkedin-badge]: https://img.shields.io/badge/LinkedIn-Follow-0A66C2?style=for-the-badge&logoColor=white
[linkedin-url]: https://www.linkedin.com/company/masterpoint-consulting
[blog-badge]: https://img.shields.io/badge/Blog-IaC_Insights-55C1B4?style=for-the-badge&logoColor=white
[blog-url]: https://masterpoint.io/updates/
[newsletter-badge]: https://img.shields.io/badge/Newsletter-Subscribe-ECE295?style=for-the-badge&logoColor=222222
[newsletter-url]: https://newsletter.masterpoint.io/
[youtube-badge]: https://img.shields.io/badge/YouTube-Subscribe-D191BF?style=for-the-badge&logo=youtube&logoColor=white
[youtube-url]: https://www.youtube.com/channel/UCeeDaO2NREVlPy9Plqx-9JQ
[release-badge]: https://img.shields.io/github/v/release/masterpointio/terraform-github-teams?color=0E383A&label=Release&style=for-the-badge&logo=github&logoColor=white
[latest-release]: https://github.com/masterpointio/terraform-github-teams/releases/latest
[contributors-image]: https://contrib.rocks/image?repo=masterpointio/terraform-github-teams
[contributors-url]: https://github.com/masterpointio/terraform-github-teams/graphs/contributors
[issues-url]: https://github.com/masterpointio/terraform-github-teams/issues
