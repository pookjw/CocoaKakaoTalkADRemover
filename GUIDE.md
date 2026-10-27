# Mac용 카카오톡 광고 제거 도구 사용 안내

이 안내는 카카오톡을 열 때 광고 제거 도구를 함께 실행하는 전용 아이콘을 만드는 방법을 설명합니다. 설치 후에는 그 아이콘을 사용해 카카오톡을 열 수 있고, Mac에 로그인할 때 자동으로 열도록 설정할 수도 있습니다.

> **먼저 확인해 주세요:** 이 도구는 카카오톡 내부의 화면 구성에 의존합니다. 카카오톡이나 macOS의 버전 및 보안 설정에 따라 작동하지 않을 수 있고, 업데이트 후에도 계속 작동한다고 보장할 수 없습니다. 아래 단계에 따라 광고가 실제로 사라지는지 확인해 주세요.

## 준비하기

- 카카오톡이 `/Applications/KakaoTalk.app`에 설치된 Mac과 인터넷 연결이 필요합니다.
- 이 도구는 카카오톡 26.9.0의 내부 구조를 기준으로 작성되었습니다. 다른 버전에서는 작동 여부를 확인해야 합니다.
- 시작하기 전에 카카오톡을 완전히 종료합니다. 화면 맨 위에서 **카카오톡 → 카카오톡 종료**를 누르세요. 창의 빨간 버튼만 누르면 앱이 계속 실행 중일 수 있습니다.

## 1. 개발 도구 설치하기

1. 키보드에서 **Command(⌘) + 스페이스바**를 누릅니다.
2. `터미널`을 입력하고 Enter를 누릅니다.
3. 아래 명령어를 복사해 터미널에 붙여 넣고 Enter를 누릅니다.

```sh
xcode-select --install
```

설치 창이 나오면 안내에 따라 설치하세요. 이미 설치되어 있다는 메시지가 나오면 다음 단계로 넘어가세요.

## 2. 전용 실행 아이콘 만들기

아래 코드 블록 오른쪽 위의 **복사 버튼**을 눌러 내용을 전부 복사하세요. 터미널에 붙여 넣고 Enter를 누르면 내려받기와 빌드가 시작됩니다. 마지막에 `완료`가 표시되면 아이콘이 만들어진 것입니다. 오류가 표시되면 다음 단계로 넘어가지 마세요.

```sh
(
set -e
if [ -e "$HOME/Applications/카카오톡 광고 제거.app" ]; then
  echo '기존 실행 아이콘이 있습니다. 앱을 변경하려면 기존 아이콘을 삭제한 뒤 다시 실행하세요.'
  exit 1
fi
mkdir -p "$HOME/Applications" "$HOME/Library/Application Support/CocoaKakaoTalkADRemover"
task_dir=$(mktemp -d)
trap 'rm -rf "$task_dir"' EXIT
curl -fL https://github.com/pookjw/CocoaKakaoTalkADRemover/archive/refs/heads/main.zip -o "$task_dir/source.zip"
unzip -q "$task_dir/source.zip" -d "$task_dir"
xcrun clang -fobjc-arc -dynamiclib -framework AppKit \
  "$task_dir/CocoaKakaoTalkADRemover-main/CocoaKakaoTalkADRemover/init.m" \
  -o "$HOME/Library/Application Support/CocoaKakaoTalkADRemover/AdHide.dylib"
osacompile -o "$task_dir/카카오톡 광고 제거.app" <<'APPLESCRIPT'
on run
    do shell script "if /usr/bin/pgrep -x KakaoTalk >/dev/null; then exit 0; fi; DYLD_INSERT_LIBRARIES=\"$HOME/Library/Application Support/CocoaKakaoTalkADRemover/AdHide.dylib\" /Applications/KakaoTalk.app/Contents/MacOS/KakaoTalk >>\"$HOME/Library/Application Support/CocoaKakaoTalkADRemover/launch.log\" 2>&1 </dev/null &"
end run
APPLESCRIPT
mv "$task_dir/카카오톡 광고 제거.app" "$HOME/Applications/카카오톡 광고 제거.app"
printf '\n완료: 홈 폴더의 응용 프로그램에 카카오톡 광고 제거 아이콘을 만들었습니다.\n'
)
```

이 명령은 GitHub에서 소스 코드를 내려받아 사용자 계정에 도구를 만듭니다. 카카오톡 원본 앱은 수정하지 않습니다. 기존 실행 아이콘이 있으면 교체하지 않고 안내 메시지를 표시합니다. 실행 아이콘을 다시 만들려면 먼저 홈 폴더의 **응용 프로그램**에서 기존 **카카오톡 광고 제거** 아이콘을 삭제하세요.

## 3. 카카오톡 실행하기

1. **Finder**를 엽니다.
2. 화면 맨 위에서 **이동 → 홈**을 누릅니다.
3. 홈 폴더의 **응용 프로그램** 폴더를 엽니다. Mac 전체의 응용 프로그램 폴더와는 다른 곳입니다.
4. **카카오톡 광고 제거**를 두 번 클릭합니다.
5. 카카오톡이 열리면 친구 목록 아래 광고가 사라졌는지 확인합니다.

처음 실행할 때 앱을 열 수 없다고 표시되면, 아이콘을 Control 키를 누른 채 클릭하고 **열기**를 선택한 뒤 화면의 안내를 확인하세요. 전용 아이콘을 Dock에 고정해 두면 다음에도 쉽게 실행할 수 있습니다.

이미 카카오톡이 실행 중이면 전용 아이콘을 눌러도 실행 중인 앱에는 적용되지 않습니다. 카카오톡을 완전히 종료한 다음 전용 아이콘으로 다시 여세요. 일반 카카오톡 아이콘으로 열 때도 광고 제거가 적용되지 않습니다.

## 4. Mac에 로그인할 때 자동으로 열기

**3단계에서 광고가 사라지는 것을 먼저 확인한 뒤** 설정하세요.

1. **시스템 설정 → 일반 → 로그인 항목 및 확장 프로그램**을 엽니다. macOS 버전에 따라 메뉴 이름이 조금 다를 수 있습니다.
2. 로그인할 때 열리는 항목 아래의 **+** 버튼을 누릅니다.
3. 홈 폴더의 **응용 프로그램 → 카카오톡 광고 제거**를 선택합니다.
4. 기존 **카카오톡**이 로그인 항목에 있다면 중복 실행을 피하도록 해당 항목을 선택하고 **−** 버튼을 누릅니다.

이제 Mac에 로그인할 때 전용 아이콘이 실행됩니다. 카카오톡을 직접 종료한 후 다시 열 때도 일반 카카오톡 아이콘 대신 전용 아이콘을 사용해야 합니다.

## 문제가 생겼을 때

- **광고가 그대로 보입니다:** 카카오톡을 완전히 종료하고 전용 아이콘으로 다시 실행했는지 확인하세요. 그래도 보인다면 카카오톡 버전이나 macOS의 라이브러리 로드 제한 때문에 적용되지 않았을 수 있습니다. 이 도구는 로드 성공이나 광고 제거를 자동으로 확인하지 않습니다.
- **업데이트 후 광고가 다시 보입니다:** 카카오톡의 내부 화면 구성이 바뀌었을 수 있습니다. 이 저장소에 수정된 버전이 있는지 확인하세요. 새 버전을 설치할 때는 기존 전용 아이콘을 삭제하고 2단계를 다시 실행한 후 카카오톡을 종료하고 다시 여세요. 새 버전이 모든 환경에서 동작한다고 보장할 수는 없습니다.
- **전용 아이콘을 눌러도 카카오톡이 열리지 않습니다:** `/Applications` 폴더에 카카오톡이 설치되어 있는지, 일반 카카오톡 아이콘으로는 정상 실행되는지 확인하세요. Finder에서 **이동 → 폴더로 이동**을 누르고 `~/Library/Application Support/CocoaKakaoTalkADRemover/launch.log`를 입력하면 오류 기록을 확인할 수 있습니다.

## 원래대로 되돌리기

1. 시스템 설정의 로그인 항목에서 **카카오톡 광고 제거**를 삭제합니다.
2. 일반 카카오톡 아이콘으로 실행합니다.
3. 전용 아이콘도 삭제하려면 홈 폴더의 **응용 프로그램**에서 **카카오톡 광고 제거**를 삭제합니다.
4. 도구 파일도 삭제하려면 Finder에서 **이동 → 폴더로 이동**을 누르고 아래 경로를 입력해 해당 폴더를 삭제합니다.

```text
~/Library/Application Support/CocoaKakaoTalkADRemover
```

카카오톡 원본 앱은 삭제할 필요가 없습니다.
