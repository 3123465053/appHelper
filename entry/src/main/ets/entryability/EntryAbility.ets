import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { router, window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { PrivacySettings, PRIVACY_SETTINGS } from '../common/constants';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('/pages/Index'.slice(1), (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');

      //UI变量持久化
      //是显示隐私空间还是日历清理
      PersistentStorage.persistProp('isHidePrivacy',false)
      //存储隐私空间设置相关信息
      PersistentStorage.persistProp<PrivacySettings>(PRIVACY_SETTINGS,{})
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  //进入后台
  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');

    //获取当前页面
    const routeState=router.getState()
    //当前页面路由包含pages/Privacy(隐私相关页面) 就返回主页
    if(routeState.path.includes('pages/Privacy')){
      router.back({url:"pages/Index"})
    }
  }
}
