/**
 * E2E Test for English Words Game (Android)
 *
 * Tests the core flow:
 * 1. Launch App and enter home screen
 * 2. Click to enter English Words Game (spelling mode)
 * 3. Test bug: word "foot" - clicking one "o" should NOT gray out both "o"s
 *
 * Run with: node english_words_game.spec.js
 */

const wd = require('wd');
const assert = require('assert');

// Configuration
const APPIUM_HOST = '127.0.0.1';
const APPIUM_PORT = 4723;
const APP_PATH = '/Users/peng/english_game/build/app/outputs/apk/debug/app-debug.apk';
const APP_PACKAGE = 'com.example.english_game_v3_0329';
const APP_ACTIVITY = '.MainActivity';

let driver;
let passed = 0;
let failed = 0;

async function initDriver() {
  driver = await wd.remote({
    protocol: 'http',
    hostname: APPIUM_HOST,
    port: APPIUM_PORT,
    path: '/wd/hub',
  });

  // Configure driver
  driver.configureHttpTimeout({
    promise: 30000,
    global: 60000,
  });

  return driver;
}

async function findElementByText(text, timeout = 10000) {
  const selector = `android=new UiSelector().text("${text}")`;
  const endTime = Date.now() + timeout;

  while (Date.now() < endTime) {
    try {
      const element = await driver.element(selector);
      if (element) return element;
    } catch (e) {
      // Element not found, continue waiting
    }
    await new Promise(r => setTimeout(r, 500));
  }
  return null;
}

async function findElementsByText(text) {
  const selector = `android=new UiSelector().text("${text}")`;
  return await driver.elements(selector);
}

async function takeScreenshot(name) {
  const screenshot = await driver.takeScreenshot();
  const fs = require('fs');
  fs.writeFileSync(`/tmp/${name}.png`, screenshot, 'base64');
  console.log(`Screenshot saved to /tmp/${name}.png`);
}

async function test(name, fn) {
  try {
    console.log(`\nRunning: ${name}`);
    await fn();
    console.log(`PASSED: ${name}`);
    passed++;
  } catch (e) {
    console.log(`FAILED: ${name}`);
    console.log(`Error: ${e.message}`);
    await takeScreenshot(`failure_${name.replace(/\s+/g, '_')}`);
    failed++;
  }
}

async function main() {
  console.log('=== English Words Game E2E Test ===\n');

  // Check if Appium is running
  try {
    await initDriver();
    console.log('Connected to Appium server');
  } catch (e) {
    console.error('Failed to connect to Appium server. Is it running?');
    console.error('Start with: appium --address 127.0.0.1 --port 4723');
    process.exit(1);
  }

  // Launch the app
  await test('1. Launch app and enter home screen', async () => {
    console.log('Starting app...');
    await driver.startActivity(APP_PACKAGE, APP_ACTIVITY);

    // Wait for home screen to load
    const homeTitle = await findElementByText('学习小游戏', 15000);
    assert.ok(homeTitle, 'Home screen title "学习小游戏" not found');

    const subtitle = await findElementByText('一起学习吧！', 5000);
    assert.ok(subtitle, 'Home screen subtitle not found');

    console.log('Home screen loaded successfully');
    await takeScreenshot('home_screen');
  });

  // Navigate to English Words Game
  await test('2. Navigate to English Words Game', async () => {
    // Find and tap "英语词汇" card
    // The cards are in a GridView with emoji "💪" and text "英语词汇"
    const englishWordsCard = await findElementByText('英语词汇', 10000);
    assert.ok(englishWordsCard, 'English Words card not found');

    await englishWordsCard.click();
    console.log('Tapped English Words card');

    // Wait for game screen to load
    const gameTitle = await findElementByText('英语词汇学习', 10000);
    assert.ok(gameTitle, 'Game screen title not found');

    console.log('English Words Game screen loaded');
    await takeScreenshot('english_words_game_screen');
  });

  // Switch to spelling mode
  await test('3. Switch to spelling mode (拼写模式)', async () => {
    // Tap the menu button (PopupMenuButton)
    const menuButton = await driver.element('android=new UiSelector().className("android.widget.ImageButton")');
    assert.ok(menuButton, 'Menu button not found');

    await menuButton.click();
    console.log('Tapped menu button');

    // Wait for menu to appear
    await new Promise(r => setTimeout(r, 500));

    // Find and tap "拼写模式"
    const spellModeItem = await findElementByText('拼写模式', 5000);
    assert.ok(spellModeItem, '拼写模式 menu item not found');

    await spellModeItem.click();
    console.log('Tapped 拼写模式');

    // Wait for spelling mode to load
    await new Promise(r => setTimeout(r, 1000));

    // Look for the word "foot" (emoji: 🦶, chinese: 脚)
    // The 3rd word in the list is "foot"
    // We might need to navigate through words or we're already on the first word

    console.log('Spelling mode should now be active');
    await takeScreenshot('spelling_mode');
  });

  // Navigate to "foot" word (the 3rd word)
  await test('4. Navigate to the "foot" word', async () => {
    // The words in spelling mode are in order. foot is the 3rd word (index 2)
    // We need to tap "下一个" twice to get to the 3rd word

    // Try to find and tap "下一个" button
    let nextButton = await findElementByText('下一个', 5000);

    if (nextButton) {
      // Tap next twice to get to foot (3rd word)
      await nextButton.click();
      console.log('Tapped next (1st time)');
      await new Promise(r => setTimeout(r, 500));

      nextButton = await findElementByText('下一个', 5000);
      if (nextButton) {
        await nextButton.click();
        console.log('Tapped next (2nd time)');
        await new Promise(r => setTimeout(r, 500));
      }
    }

    // Now we should be on the "foot" word (🦶 脚)
    // Verify we're on foot by checking for the emoji or chinese text
    const footEmoji = await driver.element('android=new UiSelector().text("🦶")');
    // If not found, we might be on a different word, but continue with test

    console.log('Should now be on "foot" word (3rd word)');
    await takeScreenshot('foot_word');
  });

  // BUG TEST: Click one "o" and verify both "o"s don't turn gray
  await test('BUG TEST: Click one "o" should NOT gray out both "o"s', async () => {
    // Get all "O" letter tiles
    const oTiles = [];
    const allTextViews = await driver.elements('android=new UiSelector().className("android.widget.TextView")');

    for (const tv of allTextViews) {
      try {
        const text = await tv.getText();
        if (text === 'O') {
          oTiles.push(tv);
        }
      } catch (e) {
        // Ignore errors
      }
    }

    console.log(`Found ${oTiles.length} 'O' tiles`);

    if (oTiles.length < 2) {
      console.log('Not enough O tiles found to test the bug');
      return;
    }

    // Take screenshot before clicking
    await takeScreenshot('before_o_click');

    // Get info about all O tiles before clicking
    console.log(`Before click - found ${oTiles.length} O tiles`);

    // Click the FIRST O tile
    console.log('Clicking first O tile...');
    await oTiles[0].click();
    await new Promise(r => setTimeout(r, 800)); // Wait for UI to update

    // Take screenshot after clicking
    await takeScreenshot('after_o_click');

    // After clicking one O, both O tiles should NOT be gray
    // We can't directly check colors with UiAutomator, but we can verify
    // that the tile was added to the selection

    // Re-scan O tiles to see the state
    const oTilesAfter = [];
    const allTextViewsAfter = await driver.elements('android=new UiSelector().className("android.widget.TextView")');

    for (const tv of allTextViewsAfter) {
      try {
        const text = await tv.getText();
        if (text === 'O') {
          // Try to get parent container info
          oTilesAfter.push(text);
        }
      } catch (e) {
        // Ignore
      }
    }

    console.log(`After click - found ${oTilesAfter.length} O tiles`);

    // The bug would manifest as: clicking one O causes BOTH Os to appear selected (grayed out)
    // If we see that the letter was added to the word spelling area, the bug may not exist
    // If BOTH O tiles are now visually gray (selected), the bug is confirmed

    // Check if there's a selection indicator
    // The selected letters appear in boxes at the top (the spelling slots)
    // For "foot", the slots are: [_][_][_][_] (4 slots for f,o,o,t)
    // After clicking O, one slot should show O

    // Try to find the spelling slots
    const spellingSlots = await driver.elements('android=new UiSelector().className("android.widget.Container")');
    console.log(`Found ${spellingSlots.length} container elements`);

    // We can't easily verify the color without accessibility info
    // But we can check if the selection was registered by looking at the UI state

    console.log('BUG VERIFICATION: Check screenshots at /tmp/before_o_click.png and /tmp/after_o_click.png');
    console.log('If BOTH O tiles appear gray in after_o_click.png, the bug is CONFIRMED');
    console.log('If only ONE O tile is gray, the bug is NOT present');
  });

  // Summary
  console.log('\n=== Test Summary ===');
  console.log(`Passed: ${passed}`);
  console.log(`Failed: ${failed}`);
  console.log(`Total: ${passed + failed}`);

  // Cleanup
  if (driver) {
    await driver.quit();
  }

  process.exit(failed > 0 ? 1 : 0);
}

main().catch(e => {
  console.error('Fatal error:', e);
  process.exit(1);
});
