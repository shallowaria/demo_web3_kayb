# 代理配置说明

## 为什么需要代理？

由于网络环境限制，可能无法直接访问 OKX API（`web3.okx.com`）。应用已支持通过本地代理访问外部 API。

## 配置步骤

### 1. 确保代理工具运行

确保你的代理工具正在运行，常见工具：
- **Clash for Windows** - 默认端口 7890
- **V2Ray** - HTTP 端口通常是 10809
- **Shadowsocks** - SOCKS5 端口通常是 1080

### 2. 查看代理端口

不同工具查看端口的方法：

**Clash for Windows:**
- 打开 Clash
- 在主界面查看 "Port" 或 "HTTP(S) 代理端口"
- 通常是 `7890`

**V2Ray:**
- 查看 V2Ray 配置
- 找到 HTTP 入站端口
- 通常是 `10809`

**系统代理设置:**
- Windows 设置 → 网络和 Internet → 代理
- 查看 "手动设置代理" 中的地址和端口

### 3. 配置应用代理

打开文件：`lib/data/config/proxy_config.dart`

修改配置：

```dart
const ProxyConfig proxyConfig = ProxyConfig(
  enabled: true,              // ✅ 设置为 true 启用代理
  host: '127.0.0.1',         // 代理地址（本地代理通常是 127.0.0.1）
  port: 7890,                // ⚠️ 修改为你的代理端口
);
```

### 4. 常见配置示例

**Clash:**
```dart
const ProxyConfig proxyConfig = ProxyConfig(
  enabled: true,
  host: '127.0.0.1',
  port: 7890,
);
```

**V2Ray (HTTP):**
```dart
const ProxyConfig proxyConfig = ProxyConfig(
  enabled: true,
  host: '127.0.0.1',
  port: 10809,
);
```

**自定义代理:**
```dart
const ProxyConfig proxyConfig = ProxyConfig(
  enabled: true,
  host: '你的代理地址',
  port: 你的代理端口,
);
```

### 5. 测试代理

配置完成后，重启应用：

```bash
flutter run
```

进入"支持的链"页面，如果配置正确，应该能成功加载链列表。

## 故障排查

### 问题：仍然显示连接超时

**解决方法：**
1. 确认代理工具正在运行
2. 检查代理端口是否正确
3. 尝试在浏览器中访问 https://web3.okx.com 测试代理是否生效
4. 检查代理工具的系统代理模式（全局模式/规则模式）

### 问题：证书错误

应用已配置忽略证书验证（`badCertificateCallback`），这在开发环境中是安全的。

### 问题：端口冲突

如果代理端口被占用，代理工具会显示错误。尝试：
1. 重启代理工具
2. 更换代理端口
3. 检查是否有其他程序占用该端口

## 代码说明

代理配置位于：
- **配置文件**: `lib/data/config/proxy_config.dart`
- **Dio 客户端**: `lib/data/api/dio_client.dart`

超时时间已增加到 30 秒，适应代理环境的网络延迟。

## 禁用代理

如果不需要代理（例如在海外服务器运行），设置：

```dart
const ProxyConfig proxyConfig = ProxyConfig(
  enabled: false,  // 禁用代理
);
```
