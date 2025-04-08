# 🧑‍💻 Contributing to Rubee

Hey there! 👋 First of all, thanks for being interested in contributing to **Rubee** — we appreciate it a lot. Whether you're here to fix a bug, suggest an idea, improve the docs, or add a shiny new feature, you're more than welcome.

This guide is here to help you get started smoothly. Let's make this a fun and collaborative experience!

---

## 🤔 Where Do I Start?

Here are a few ways to jump in:

- **Found a bug?** Open an [issue](https://github.com/nucleom42/rubee/issues) or, even better, a PR to fix it.
- **Got a feature idea?** Share it in [Ideas & Feature Requests](https://github.com/nucleom42/rubee/discussions/categories/ideas-feature-requests) or open a draft PR.
- **Want to help but not sure how?** Check out the `#good-first-issue` label or see the [Projects](https://github.com/nucleom42/rubee/projects) tab.
- **Have questions or want to chat?** Join the discussion section or [start a new thread](https://github.com/nucleom42/rubee/discussions).

---

## 🛠 Setting Up Your Dev Environment

1. Fork the repo
2. Clone your fork
   ```bash
   git clone https://github.com/YOUR_USERNAME/rubee.git
   cd rubee
   ```

3. Install dependencies
   ```bash
   bundle install
   ```

4. Run migrations
   ```bash
   bin/rubee db run:all
   ```

5. Run tests
   ```bash
   RACK_ENV=test bin/rubee test
   ```

## 💡 Tip: Want to see how things work? Check out lib/rubee.rb and follow the trail from there.

## 🚀 Making a Change

1. Create a new branch
```bash
    git checkout -b your-branch-name
```
2. Make your changes ✨

3. Run tests ✅

4. Commit clearly
```bash
    git commit -m "Fix: explain clearly what you changed"
```
5. Push and open a pull request 🙌

    We ❤️ clean and well-documented code. Add comments where it helps, and don’t stress perfection — we’ll help review.

✅ Code Style & Conventions
    Stick to standard Ruby formatting (2-space indent, snake_case, etc.). Run rubocop to ensure your code is clean.
    Follow the existing project structure unless you have a good reason to shift it.
    Keep things simple and readable
