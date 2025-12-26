# AGENTS.md

这个APP是一本数字化的路书，提供岩场的信息，以及岩友的经验分享、记录和交流平台。

## 项目架构设计

使用 Flutter2.0 及以上版本开发，采用 Riverpod3.x 作为状态管理方案。

```text
lib/
├── main.dart
├── src/models/     // 数据模型
├── src/services/   // 数据接口服务，目前使用fake数据模拟数据库
├── src/provider/   // 状态管理与业务逻辑，把 services 的结果组织成 UI 可消费的状态
├── src/view/       // 页面 UI 层
```

推荐的单向依赖关系：views → providers → services → models

禁止或应避免：
services 依赖 providers
models 依赖 services / providers
views 直接调用 services

## 开发时

- 使用 Flutter 进行跨平台开发。
- 每次更新完成后，修改内容应该总结在 docs/agent_logs.md 里。使用中文。使用二级标题，标题为当前git分支的名称。
