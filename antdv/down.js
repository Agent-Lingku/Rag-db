const puppeteer = require("puppeteer");
const fs = require("fs");
const path = require("path");

// 定义要请求的 URL 列表
const urls = [
  "https://www.antdv.com/components/affix-cn",
  "https://www.antdv.com/components/config-provider-cn",
  "https://www.antdv.com/components/float-button-cn",
  "https://www.antdv.com/components/watermark-cn",
  "https://www.antdv.com/components/button-cn",
  "https://www.antdv.com/components/icon-cn",
  "https://www.antdv.com/components/typography-cn",
  "https://www.antdv.com/components/divider-cn",
  "https://www.antdv.com/components/flex-cn",
  "https://www.antdv.com/components/grid-cn",
  "https://www.antdv.com/components/layout-cn",
  "https://www.antdv.com/components/space-cn",
  "https://www.antdv.com/components/anchor-cn",
  "https://www.antdv.com/components/breadcrumb-cn",
  "https://www.antdv.com/components/dropdown-cn",
  "https://www.antdv.com/components/menu-cn",
  "https://www.antdv.com/components/page-header-cn",
  "https://www.antdv.com/components/pagination-cn",
  "https://www.antdv.com/components/steps-cn",
  "https://www.antdv.com/components/auto-complete-cn",
  "https://www.antdv.com/components/cascader-cn",
  "https://www.antdv.com/components/checkbox-cn",
  "https://www.antdv.com/components/date-picker-cn",
  "https://www.antdv.com/components/form-cn",
  "https://www.antdv.com/components/input-cn",
  "https://www.antdv.com/components/input-number-cn",
  "https://www.antdv.com/components/mentions-cn",
  "https://www.antdv.com/components/radio-cn",
  "https://www.antdv.com/components/rate-cn",
  "https://www.antdv.com/components/select-cn",
  "https://www.antdv.com/components/slider-cn",
  "https://www.antdv.com/components/switch-cn",
  "https://www.antdv.com/components/time-picker-cn",
  "https://www.antdv.com/components/transfer-cn",
  "https://www.antdv.com/components/tree-select-cn",
  "https://www.antdv.com/components/upload-cn",
  "https://www.antdv.com/components/avatar-cn",
  "https://www.antdv.com/components/badge-cn",
  "https://www.antdv.com/components/calendar-cn",
  "https://www.antdv.com/components/card-cn",
  "https://www.antdv.com/components/carousel-cn",
  "https://www.antdv.com/components/collapse-cn",
  "https://www.antdv.com/components/comment-cn",
  "https://www.antdv.com/components/descriptions-cn",
  "https://www.antdv.com/components/empty-cn",
  "https://www.antdv.com/components/image-cn",
  "https://www.antdv.com/components/list-cn",
  "https://www.antdv.com/components/popover-cn",
  "https://www.antdv.com/components/qrcode-cn",
  "https://www.antdv.com/components/segmented-cn",
  "https://www.antdv.com/components/statistic-cn",
  "https://www.antdv.com/components/table-cn",
  "https://www.antdv.com/components/tabs-cn",
  "https://www.antdv.com/components/alert-cn",
  "https://www.antdv.com/components/drawer-cn",
  "https://www.antdv.com/components/message-cn",
  "https://www.antdv.com/components/modal-cn",
  "https://www.antdv.com/components/notification-cn",
  "https://www.antdv.com/components/popconfirm-cn",
  "https://www.antdv.com/components/progress-cn",
  "https://www.antdv.com/components/result-cn",
  "https://www.antdv.com/components/skeleton-cn",
  "https://www.antdv.com/components/spin-cn",
];

// 异步函数，用于处理每个 URL
async function fetchAndSave(page, url) {
  try {
    // 导航到目标 URL，并等待网络空闲
    await page.goto(url, { waitUntil: "networkidle2", timeout: 60000 });

    // 获取页面的完整 HTML 内容
    const content = await page.content();

    // 使用 JSDOM 解析 HTML 并提取 body 的文本内容
    const dom = new (require("jsdom").JSDOM)(content);
    const bodyText = dom.window.document.body.textContent || "";

    // 清理文本内容（可选）
    // 你可以根据需要进一步处理 bodyText，例如去除多余的空格、换行等

    // 从 URL 中提取组件名称，作为文件名（去除 .cn 后缀，并将 '-' 替换为 '_'）
    const urlParts = url.split("/");
    let fileName = urlParts[urlParts.length - 1]; // 如 'affix-cn'
    if (fileName.endsWith(".cn")) {
      fileName = fileName.slice(0, -3); // 去掉 '.cn'
    }
    fileName = "res/" + fileName.replace(/-/g, "_") + ".txt"; // 将 '-' 替换为 '_'

    // 将文本内容写入文件
    const filePath = path.join(__dirname, fileName);
    fs.writeFileSync(filePath, bodyText, "utf-8");

    console.log(`已保存: ${fileName}`);
  } catch (error) {
    console.error(`获取或保存 ${url} 时出错:`, error);
  }
}

// 主函数，用于遍历所有 URL 并依次处理
async function main() {
  // 启动浏览器实例
  const browser = await puppeteer.launch({
    headless: true, // 设置为 false 可以查看浏览器界面（调试时有用）
    // executablePath: '/path/to/chromium', // 如果需要特定版本的 Chromium
    args: ["--no-sandbox", "--disable-setuid-sandbox"], // 根据需要添加参数
  });

  // 创建一个新的页面
  const page = await browser.newPage();

  // 设置视口大小（可选）
  await page.setViewport({ width: 1280, height: 800 });

  // 设置用户代理（模拟特定浏览器）
  await page.setUserAgent(
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36"
  );

  // 遍历所有 URL 并依次处理
  for (const url of urls) {
    await fetchAndSave(page, url);
  }

  // 关闭浏览器实例
  await browser.close();

  console.log("所有文件已处理完成。");
}

// 执行主函数
main().catch((error) => {
  console.error("运行过程中发生错误:", error);
});
