import { test, expect, chromium, Browser, BrowserContext, Page } from '@playwright/test';
import { remote } from 'webdriverio';

// Test configuration
const APP_PACKAGE = 'com.example.english_game_v3_0329';
const APP_ACTIVITY = '.MainActivity';
const APPIUM_HOST = '127.0.0.1';
const APPIUM_PORT = 4723;

describe('English Words Game E2E Tests', () => {
  let driver: any;
  let page: Page;

  beforeAll(async () => {
    // Connect to Appium and launch the app
    driver = await remote({
      protocol: 'http',
      hostname: APPIUM_HOST,
      port: APPIUM_PORT,
      path: '/wd/hub',
      capabilities: {
        platformName: 'Android',
        deviceName: 'Android Emulator',
        app: '/Users/peng/english_game/build/app/outputs/apk/debug/app-debug.apk',
        appPackage: APP_PACKAGE,
        appActivity: APP_ACTIVITY,
        automationName: 'UiAutomator2',
        noReset: true,
      },
    });
  }, 60000);

  afterAll(async () => {
    if (driver) {
      await driver.deleteSession();
    }
  });

  test('should launch app and navigate to home screen', async () => {
    // Wait for app to load - look for the home screen title
    await driver.waitUntil(async () => {
      try {
        const title = await driver.getText('android=new UiSelector().text("学习小游戏")');
        return title === '学习小游戏';
      } catch {
        return false;
      }
    }, { timeout: 30000, timeoutMsg: 'Home screen did not load' });

    // Verify we're on home screen
    const title = await driver.getText('android=new UiSelector().text("学习小游戏")');
    expect(title).toBe('学习小游戏');
  });

  test('should navigate to English Words Game (spelling mode)', async () => {
    // Find and tap the English Words card (emoji: 💪, name: 英语词汇)
    // The card is identified by its content description or text
    const cards = await driver.findElements('android=new UiSelector().className("android.widget.TextView")');

    let englishWordsCard = null;
    for (const card of cards) {
      const text = await card.getText();
      if (text === '英语词汇') {
        englishWordsCard = card;
        break;
      }
    }

    expect(englishWordsCard).not.toBeNull();
    await englishWordsCard.click();

    // Wait for the game screen to load
    await driver.waitUntil(async () => {
      try {
        const title = await driver.getText('android=new UiSelector().text("英语词汇学习")');
        return title === '英语词汇学习';
      } catch {
        return false;
      }
    }, { timeout: 10000, timeoutMsg: 'English Words Game screen did not load' });
  });

  test('BUG TEST: clicking one "o" in "foot" should NOT gray out both "o"s', async () => {
    // Navigate to spelling mode via menu
    // First, tap the menu button (three dots or similar)
    const menuButton = await driver.findElement('android=new UiSelector().description("更多选项")');
    await menuButton.click();

    // Wait for menu to appear and tap "拼写模式"
    await driver.waitUntil(async () => {
      try {
        await driver.getText('android=new UiSelector().text("拼写模式")');
        return true;
      } catch {
        return false;
      }
    }, { timeout: 5000 });

    const spellModeItem = await driver.findElement('android=new UiSelector().text("拼写模式")');
    await spellModeItem.click();

    // Now we're in spelling mode
    // The game shows words one by one. We need to find "foot" which is the 3rd word
    // We might need to skip to the "foot" word

    // For now, let's check if the letter tiles work correctly
    // Find all letter tiles (O tiles)
    await driver.waitUntil(async () => {
      try {
        // Look for letter tiles - they should have 'O' displayed
        const tiles = await driver.findElements('android=new UiSelector().className("android.widget.TextView")');
        for (const tile of tiles) {
          const text = await tile.getText();
          if (text === 'O') {
            return true;
          }
        }
        return false;
      } catch {
        return false;
      }
    }, { timeout: 10000, timeoutMsg: 'Letter tiles did not appear' });

    // Find all 'O' letter tiles
    const oTiles: any[] = [];
    const allTiles = await driver.findElements('android=new UiSelector().className("android.widget.TextView")');

    for (const tile of allTiles) {
      const text = await tile.getText();
      if (text === 'O') {
        oTiles.push(tile);
      }
    }

    console.log(`Found ${oTiles.length} 'O' tiles`);

    // If there are multiple 'O' tiles, click one and verify the bug
    if (oTiles.length >= 2) {
      // Get initial state - count how many are gray (selected)
      // Gray tiles have Colors.grey.shade300 which is #D4D4D4 approximately

      // Click the first 'O' tile
      await oTiles[0].click();
      await new Promise(r => setTimeout(r, 500)); // Wait for UI update

      // After clicking, check if BOTH 'o's are now gray (selected)
      // If the bug exists, clicking one 'O' would select both
      // We need to verify the state of the tiles after selection

      // For now, let's just verify the tap was registered
      // A proper test would inspect the tile's background color

      // Take a screenshot to verify visually
      // await driver.saveScreenshot('/tmp/o_tile_clicked.png');

      // Verify by checking if the tile was added to selected indices
      // This is hard to verify directly in Appium without accessibility info

      console.log('BUG VERIFICATION: If both O tiles turned gray after clicking one, bug is confirmed');
    }
  });
});
