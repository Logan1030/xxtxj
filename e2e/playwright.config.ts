import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  fullyParallel: false,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: 1,
  reporter: [
    ['html', { outputFolder: 'playwright-report' }],
    ['list'],
  ],
  use: {
    baseURL: 'http://localhost:8080',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    {
      name: 'ios-simulator',
      use: {
        ...devices['iPhone 17 Pro'],
        launchOptions: {
          args: ['-F', '/Users/peng/xxtxj/build/ios/iphonesimulator/Runner.app'],
        },
      },
    },
  ],
  webServer: undefined,
});
