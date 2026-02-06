# OKX API 配置说明

## 获取 API 密钥

1. 访问 [OKX API 管理页面](https://www.okx.com/account/my-api)
2. 登录你的 OKX 账户
3. 点击"创建 API"按钮
4. 设置以下信息：
   - API 名称：随意命名（例如：Web3Demo）
   - API 权限：选择"只读"（Read only）即可
   - IP 白名单：可选，建议留空用于开发
   - Passphrase：设置一个密码短语（请记住它！）
5. 创建后，你会获得三个重要信息：
   - **API Key**
   - **Secret Key** （只显示一次，请立即保存！）
   - **Passphrase** （你刚才设置的）

## 配置 API 密钥

打开文件：`lib/data/config/api_credentials.dart`

将你的 API 凭证填入：

```dart
const OkxApiConfig okxApiConfig = OkxApiConfig(
  apiKey: 'YOUR_API_KEY_HERE',        // 替换为你的 API Key
  secretKey: 'YOUR_SECRET_KEY_HERE',  // 替换为你的 Secret Key
  passphrase: 'YOUR_PASSPHRASE_HERE', // 替换为你的 Passphrase
);
```

## 安全提示

⚠️ **重要：永远不要将真实的 API 密钥提交到 Git 仓库！**

- `api_credentials.dart` 已被添加到 `.gitignore`
- 在生产环境中，应使用环境变量或安全存储
- 建议只授予 API 只读权限
- 定期轮换 API 密钥

## 测试

配置完成后，运行应用：

```bash
flutter run
```

导航到"支持的链"页面，应该能看到从 OKX API 获取的区块链列表。

## 认证原理

应用使用 HMAC SHA256 签名来认证 OKX API 请求：

1. 生成 UTC 时间戳
2. 构建签名字符串：`timestamp + method + requestPath + body`
3. 使用 Secret Key 进行 HMAC SHA256 加密
4. Base64 编码签名
5. 添加认证头：
   - `OK-ACCESS-KEY`
   - `OK-ACCESS-SIGN`
   - `OK-ACCESS-TIMESTAMP`
   - `OK-ACCESS-PASSPHRASE`

相关代码见：`lib/data/api/okx_chain_api_client.dart`
