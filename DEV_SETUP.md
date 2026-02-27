# 🏡 Arrow Escape - 홈/로컬 개발 환경 구축 가이드

아무것도 설치되지 않은 PC(집 컴퓨터 등)에서 처음부터 Flutter 개발 환경을 구축하고, Arrow Escape 프로젝트를 실행하는 완벽한 가이드입니다. Java SDK나 Gradle을 개별적으로 설치하다 보면 충돌이 잦습니다. **Android Studio를 설치하면 Java와 Gradle이 한 번에 해결됩니다.**

---

## 🛠️ 1단계: 필수 프로그램 다운로드 및 설치

### 1. Git 설치
* 다운로드: [Git for Windows](https://git-scm.com/download/win)
* 설치 시 모든 기본값(Next)을 유지하며 설치합니다.

### 2. Android Studio 설치 (가장 중요 🌟)
**Java(JDK)와 Gradle, 안드로이드 에뮬레이터 문제**를 한 방에 해결해 주는 핵심입니다.
* 다운로드: [Android Studio](https://developer.android.com/studio)
* 설치 후 처음 실행할 때 뜨는 **기본 설정 마법사(Standard Setup)**를 끝까지 완료하세요. (이 과정에서 필요한 Android SDK, Java, 빌드 툴 등이 자동 설치됩니다.)

### 3. Flutter SDK 설치
* 다운로드: [Flutter Windows SDK](https://docs.flutter.dev/get-started/install/windows) (최신 Stable 버전의 `.zip` 파일 다운로드)
* **압축 풀기**: `C:\src\flutter` 같은 경로를 만들어 압축을 풉니다. (`C:\Program Files` 처럼 권한이 필요한 곳은 절대 피하세요!)

### 4. VS Code 설치 (코드 편집기)
* 다운로드: [Visual Studio Code](https://code.visualstudio.com/)
* 설치 후 실행하여 좌측 확장 프로그램(Extensions) 메뉴에서 다음 두 가지를 검색해 설치합니다:
  * **Flutter** (Dart도 함께 설치됨)

---

## 🔗 2단계: 환경 변수(Path) 설정
명령 프롬프트에서 `flutter` 명령어를 아무 곳에서나 쓰기 위한 작업입니다.

1. 윈도우 검색창에 **"환경 변수"** 검색 후 **[시스템 환경 변수 편집]** 실행
2. 하단의 **[환경 변수]** 버튼 클릭
3. 위쪽 '사용자에 대한 사용자 변수' 목록에서 **`Path`** 선택 후 **[편집]**
4. **[새로 만들기]** 클릭 후, 아까 Flutter 압축을 푼 폴더 안의 `bin` 폴더 경로 입력 (예: `C:\src\flutter\bin`)
5. 확인을 눌러 모두 닫습니다.

---

## 🩺 3단계: 환경 검증 및 라이선스 동의
1. 키보드의 `Win + R`을 누르고 `cmd`를 입력해 명령 프롬프트를 엽니다.
2. 아래 명령어를 차례대로 입력하고 실행합니다.
   ```bash
   flutter doctor
   ```
   > 💡 처음 실행 시 필요한 파일들을 다운로드하느라 시간이 조금 걸릴 수 있습니다.
   > `[X] Android toolchain` 오류가 뜬다면 아래 명령어로 라이선스에 동의해야 합니다.

3. 라이선스 동의 (전부 `y` 누르고 엔터)
   ```bash
   flutter doctor --android-licenses
   ```
   이후 다시 `flutter doctor`를 쳤을 때 대부분 초록색 체크(`[✓]`)가 뜨면 성공입니다.

---

## 📥 4단계: 프로젝트 다운로드 및 설정
이제 집 컴퓨터 환경이 모두 세팅되었습니다! 프로젝트를 가져옵니다.

1. 코드를 저장할 폴더를 하나 만들고, 해당 폴더에서 마우스 우클릭 -> **[Open Git Bash here]** 또는 터미널을 엽니다.
2. 깃허브에서 코드 가져오기 (본인 레포지토리 주소 입력)
   ```bash
   git clone https://github.com/[사용자명]/arrow-escape.git
   cd arrow-escape
   ```
3. 라이브러리/패키지 다운로드
   ```bash
   flutter pub get
   ```

---

## 🔐 5단계: Firebase 비밀 키퍼즐 맞추기
이 프로젝트는 Firebase를 사용합니다. 보안상 깃허브에 올리지 않은 키 파일이 반드시 필요합니다!
회사 컴퓨터에서 미리 챙겨온(또는 Firebase 콘솔에서 다운로드한) 파일을 제자리에 넣습니다.

1. `google-services.json` 파일을 복사합니다.
2. 집 컴퓨터의 `arrow-escape/android/app/` 폴더 안에 붙여넣기 합니다.

---

## ▶️ 6단계: 에뮬레이터 켜고 실행하기
1. VS Code를 열고 **[파일] -> [폴더 열기]**로 `arrow-escape` 폴더를 엽니다.
2. VS Code 하단 파란색 바(또는 우측 하단)에서 **[No Device]**라고 써진 부분을 클릭해 Android 에뮬레이터를 켭니다. (에뮬레이터가 없다면 Android Studio에서 생성해야 합니다.)
3. VS Code 터미널에서 아래 명령어를 실행하면 끝! 🎉
   ```bash
   flutter run
   ```
