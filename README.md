[![Banner][banner-image]](https://masterpoint.io/)

# terraform-github-teams

[![Release][release-badge]][latest-release]

💡 Learn more about Masterpoint [below](#who-we-are-𐦂𖨆𐀪𖠋).

## Purpose and Functionality

This Terraform module manages GitHub teams and their memberships within an organization, providing team and access management:

- **Team Management**: Create and configure teams with customizable properties, including privacy settings (secret/closed).
- **Membership Control**: Manage team memberships with maintainer or member roles, ensuring organization owners are always maintainers.
- **Repository Access**: Configure repository collaborators with granular permissions.
- **Review Request Delegation**: Set up team review request settings with configurable algorithms and member counts.
- **Built-in Validation**: Enforce best practices through automated checks for.

## Usage

### Prerequisites

1. A GitHub organization.
2. Organization admin access.
3. GitHub provider configuration with appropriate permissions.

### Basic Example

```hcl
module "github_teams" {
  source  = "masterpointio/teams/github"
  version = "X.X.X"

  github_organization = "example-org"

  teams = {
    "developers" = {
      name = "Developers"
      members = [
        {
          username = "user1"
          role     = "maintainer"
        },
        {
          username = "user2"
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

### Advanced Example with All Features

```hcl
module "github_teams" {
  source  = "masterpointio/teams/github"
  version = "X.X.X"

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
        username                    = "external-contributor"
        permission                  = "maintain"
      }
    ]
  }
}
```

### Input Variables

| Name                     | Description                                              | Type        | Required |
| ------------------------ | -------------------------------------------------------- | ----------- | -------- |
| github_organization      | The GitHub organization name                             | string      | yes      |
| teams                    | Map of teams to manage with their properties and members | map(object) | no       |
| repository_collaborators | Map of repositories to their list of collaborators       | map(list)   | no       |

For detailed type definitions and validation rules, see the [variables.tf](./variables.tf) file.

### Validation Rules

1. Team privacy must be either "secret" (default) or "closed".
2. Member roles must be either "member" (default) or "maintainer".
3. Repository collaborator permissions must be one of: "pull", "triage", "push", "maintain", "admin".
4. Repository names must follow the format "owner/repository".
5. Team map keys must match the slugified team name (lowercase, spaces replaced with hyphens).
6. Organization owners must be set as maintainers in teams.

These rules are enforced through the variable validation blocks, runtime checks, and test cases that verify all validation logic.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
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
