# AI Agent 入门指南

`my-ai-lesson-repo` 是 Sia 编写的面向非技术人员的 AI Agent 入门公开教程，采用非商业许可。

通过日常工作中的小任务，逐步理解如何准备材料、描述需求、与 AI 协作、检查结果和复用成功做法。适合自学，也可作为定制教学的基础读物；行业实战项目独立维护。

## 阅读入口

[打开教程网站](https://sia424.github.io/my-ai-lesson-repo/)

目前可阅读[第一章“认识 AI Agent”](docs/01.认识-AI-Agent.md)和[第二章“使用 Agent 前，先知道这些安全常识”](docs/02.使用-Agent-前，先知道这些安全常识.md)，涵盖基础概念、公众号写作练习、个人助手安全边界与工具保护机制。后续章节持续更新中。

- [正文目录](docs/README.md)
- [工具指南说明](guides/README.md)
- [配套材料说明](examples/README.md)

## 内容维护

- [项目规范](AGENTS.md)
- [内容规划与进度](ROADMAP.md)
- [图片与资源约定](assets/README.md)

## 网站维护

网站源文件已配置为 Jekyll 页面，章节正文仍直接维护在 `docs/` 中。`_config.yml` 定义页面布局与发布排除项，`_layouts/default.html` 和 `assets/site/style.css` 提供共享阅读界面。第三章占位内容和维护文件不会生成到网站；它们在公开仓库中仍然可见。

静态检查：

```sh
ruby scripts/check-site.rb
```

具备兼容 Ruby 与 Bundler 环境后，可将构建依赖安装到项目内并验证：

```sh
bundle config set --local path vendor/bundle
bundle install
bundle exec jekyll build
ruby scripts/check-site.rb --built
```

站点由 `main` 根目录自动构建。更新文档、运行检查并提交后，推送 `main` 即触发 Pages 更新；发布结果在仓库 Actions 中查看。维护文档与教程之外的文件不会进入网站，公开仓库中仍然可见。发布验证记录见[施工清单](PUBLISH_PLAN.md)。

## 使用许可

原创教程文字、图片及配套示例材料采用 CC BY-NC 4.0（署名与非商业性使用）。商业使用须事先获得著作权人 Sia 的书面授权。第三方内容按其原有许可使用，详细范围见 [LICENSE](LICENSE)。

本项目是采用非商业许可的公开教程，不以允许自由商业使用的开源项目名义分发。
