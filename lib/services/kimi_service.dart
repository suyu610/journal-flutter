import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class KimiVisionService {
  // ⚠️ 记得替换为你自己在 Moonshot AI 开放平台申请的 API Key
  static const String apiKey = '';
  static const String apiUrl = 'https://api.moonshot.cn/v1/chat/completions';

  /// 调用 Kimi 视觉模型分析图片并返回 JSON 格式的文案
  static Future<Map<String, dynamic>?> analyzeImage(
      File imageFile, String prompt) async {
    try {
      // 1. 将图片转换为 Base64 编码 (Kimi 视觉模型要求图片格式为 base64 或 URL)
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // 简单判断图片后缀类型
      final extension = imageFile.path.split('.').last.toLowerCase();
      final mimeType = (extension == 'png') ? 'png' : 'jpeg';

      // 2. 构造符合 Kimi API 规范的请求体
      final Map<String, dynamic> requestBody = {
        "model": "kimi-k2.5",
        "messages": [
          {
            "role": "user",
            "content": [
              {"type": "text", "text": prompt},
              {
                "type": "image_url",
                "image_url": {"url": "data:image/$mimeType;base64,$base64Image"}
              }
            ]
          }
        ],
        "thinking": {"type": "disabled"},
        "temperature": 0.6, // 稍微带一点创造力，适合写散文
        "response_format": {"type": "json_object"} // 核心：强制 Kimi 返回纯 JSON 格式！
      };

      // 3. 发送网络请求
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(requestBody),
      );

      // 4. 解析响应数据
      if (response.statusCode == 200) {
        // 坑点注意：必须使用 utf8.decode 解码 bodyBytes，否则拿到的中文散文会乱码
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        final contentStr = responseData['choices'][0]['message']['content'];

        // 将 Kimi 返回的字符串解析为 Map 给 UI 使用
        return jsonDecode(contentStr) as Map<String, dynamic>;
      } else {
        print(
            'Kimi API 请求失败: 状态码 ${response.statusCode}\n报错信息: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Kimi API 调用出错: $e');
      return null;
    }
  }
}
