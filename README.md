# 🎉 Welcome to the Ubuntu AMI Builder! 🎉

Hey there! Welcome to the place where creating a customized Ubuntu AMI (Amazon Machine Image) becomes a breeze. Whether you're a cloud newbie or a seasoned pro, this repo's got you covered!

## 🚀 What's Inside?

- **Ubuntu 24.04 LTS**: Start with the latest and greatest from Canonical.
- **Essential Packages**: Out-of-the-box tools like `curl`, `clamav`, `vim`, `git`, and more.
- **Docker and Nginx**: Ready-to-go containers and web server setups.
- **ClamAV**: Built-in security with ClamAV.

## 🔧 How to Get Started?

1. **Clone the Repo**: Grab a copy of the code.
   ```bash
   git clone https://your-repo-url.git
   cd packer-ami-builder
   ```

2. **Customize Your Build**: Make it yours with variable files!
   - Check out `variables.pkrvars.hcl` for custom settings.
   - Use `examples/minimal.pkrvars.hcl` for a light build.
   - Want all the goodies? Try `examples/development.pkrvars.hcl`.

3. **Build Your AMI**: Spam that build button!
   ```bash
   packer build -var-file="variables.pkrvars.hcl" packer.pkr.hcl
   ```

## 🔑 AWS Setup

Make sure your AWS creds are set up. You can use environment variables or the `variables.pkrvars.hcl` file.

```bash
export AWS_ACCESS_KEY_ID=your-access-key
export AWS_SECRET_ACCESS_KEY=your-secret-key
```

## ☁️ Deploy Your AMI

Sit back and watch the magic happen as your AMI builds in AWS. Pour yourself a coffee—you deserve it!

## 💌 Feedback?

We'd love to hear from you! [Submit an issue](https://gitlab.com/your-issue-tracker)
or hit us up on the [chat](https://your-chat-platform).
