# Agent Change Logs

## feat/crags-page
- 新增岩场数据模型与模拟数据，包含省份-地区-岩场层级与详情信息。
- 新增岩场相关 Provider，确保 views 通过状态层读取数据。
- 完成岩场入口、地区岩场列表、岩场详情页面的导航与展示。
- 新增线路数据模型与模拟数据，支持按岩场过滤线路。
- 新增线路筛选 Provider 与分组模型，支持多选岩场与过滤条件。
- 完成线路总览页面的工具栏、筛选弹窗与分级展示布局。
- 修正线路页面对 Riverpod notifier/provider 的使用方式，避免状态传递错误。
- 修正线路过滤状态默认空集合的类型问题。
- 将线路筛选状态改为 Riverpod 2 推荐的 Notifier Provider。
- 修正 NotifierProvider 的构造方式以匹配 Riverpod 2 类型签名。
