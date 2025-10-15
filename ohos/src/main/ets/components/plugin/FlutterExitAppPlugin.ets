import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,

} from '@ohos/flutter_ohos';
import { AbilityAware, AbilityPluginBinding } from '@ohos/flutter_ohos';
import {common, UIAbility } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
/** FlutterExitAppPlugin **/
export default class FlutterExitAppPlugin implements FlutterPlugin, MethodCallHandler , AbilityAware {
  private channel: MethodChannel | null = null;
  private static _context: Context | null = null;
  private static _uiContext: common.UIAbilityContext | null = null;
  constructor() {
  }
  static get uiContext(): common.UIAbilityContext | null {
    return FlutterExitAppPlugin._uiContext;
  }

  static get context(): common.Context | null {
    return FlutterExitAppPlugin._context;
  }

  get uiContext(): common.UIAbilityContext | null {
    return FlutterExitAppPlugin._uiContext;
  }
  getUniqueClassName(): string {
    return "FlutterExitAppPlugin"
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    FlutterExitAppPlugin._uiContext = binding.getAbility().context;
    // Called when the plugin is attached to an Ability.
  }

  onDetachedFromAbility(): void {
    // this._uiContext = null;
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "flutter_exit_app");
    this.channel.setMethodCallHandler(this)
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null)
    }
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (call.method == "getPlatformVersion") {
      result.success("OpenHarmony ^ ^ ")
    } else if (call.method == "com.laoitdev.exit.app") {
      console.info("hhhhhhhhhh")

      if (FlutterExitAppPlugin._uiContext) { // Add null check here
        try {
          FlutterExitAppPlugin._uiContext.terminateSelf()
            .then(() => {
              // 执行正常业务
              console.info('terminateSelf succeed');
              result.success("Done"); // Inform Flutter about success
            })
            .catch((err: BusinessError) => {
              // 处理业务逻辑错误
              console.error(`terminateSelf failed, code is ${err.code}, message is ${err.message}`);
              result.error("TERMINATE_FAILED", `terminateSelf failed: ${err.message}`, null);
            });
        } catch (err) {
          // 捕获同步的参数错误
          let code = (err as BusinessError).code;
          let message = (err as BusinessError).message;
          console.error(`terminateSelf failed, code is ${code}, message is ${message}`);
          result.error("TERMINATE_ERROR", `terminateSelf error: ${message}`, null);
        }
      } else {
        console.error("UIContext is null, cannot terminate self.");
        result.error("CONTEXT_NULL", "UIContext is null", null); // Inform Flutter about the error
      }

    } else {
      result.notImplemented()
    }
  }
}