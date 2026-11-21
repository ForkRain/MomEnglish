# 직접 고치고 올리는 방법

## 1. 고치기

| 바꾸고 싶은 것 | 파일 | 찾을 곳 |
|---|---|---|
| 단어 카드 글자 크기 | `index.html` | `.w-en` (영어), `.w-pr` (한글 발음), `.w-ko` (한국어 뜻)의 `font-size` |
| 홈 화면 복습 버튼 크기 | `index.html` | `.review-all` 의 `font-size` |
| 퀴즈 보기 글자 크기 | `index.html` | `.choice` 의 `font-size` |
| 결과 화면 글자 크기 | `index.html` | `.r-en`, `.r-pr`, `.r-ko` 의 `font-size` |
| 색깔 | `index.html` | 맨 위 `:root` 안의 `--bg`, `--accent` 등 |
| 단어 추가·수정 | `words.js` | `["한국어 뜻", "english", "한글 발음", "그림"]` 한 줄이 단어 하나 |

주의할 점
- **고치기 전에 편집기에서 파일을 닫았다가 다시 여세요.** 예전 내용이 열린 채로 저장하면 최근 변경이 사라집니다.
- 고친 뒤 꼭 **저장(Ctrl+S)**.
- `words.js`에서 **영어 철자를 바꾸면 그 단어의 공부 기록은 처음부터** 시작합니다. 뜻·발음·그림은 바꿔도 괜찮아요.
- 버전 번호(`version.js`)와 변경 기록(`CHANGELOG.md`)은 직접 고치지 마세요. 아래 명령이 알아서 합니다.

## 2. 내 컴퓨터에서 미리 보기 (선택)

이 폴더에서 PowerShell을 열고:

```powershell
npx --yes http-server@14.1.1 -p 8080 -c-1
```

크롬에서 `http://localhost:8080` 을 열어 확인. 끝나면 PowerShell에서 Ctrl+C.

## 3. 한 번에 올리기

이 폴더에서 PowerShell을 열고 한 줄 실행 (따옴표 안에 바꾼 내용을 적어요):

```powershell
powershell -ExecutionPolicy Bypass -File .\deploy.ps1 -Message "단어 카드 글자 크기 변경"
```

이 명령이 순서대로 해 주는 것
1. 바뀐 파일 보여주기
2. GitHub에 새 변경이 있으면 먼저 받아오기
3. 버전 올리기 (`version.js`)
4. 변경 기록 추가 (`CHANGELOG.md`)
5. 한 번 더 물어본 뒤 (y 입력) 커밋 + 버전 태그 + GitHub에 올리기
6. 사이트에 새 버전이 뜰 때까지 기다렸다가 "완료!" 표시

### 버전 올리는 정도 고르기

| 바꾼 내용 | 붙일 것 | 예 |
|---|---|---|
| 작은 수정 (글자 크기, 오타, 단어 뜻) | (아무것도 안 붙임) | 1.5.5 → 1.5.6 |
| 기능 추가·화면 변경 | `-Level minor` | 1.5.5 → 1.6 |
| 큰 개편 | `-Level major` | 1.5.5 → 2.0 |

```powershell
powershell -ExecutionPolicy Bypass -File .\deploy.ps1 -Message "새 챕터 추가" -Level minor
```

### 연습해 보기

맨 뒤에 `-DryRun` 을 붙이면 아무것도 바꾸지 않고 무엇을 할지만 보여줘요.

```powershell
powershell -ExecutionPolicy Bypass -File .\deploy.ps1 -Message "연습" -DryRun
```

## 4. 엄마 폰에 반영

인터넷이 될 때 앱을 한두 번 껐다 켜면 새 버전이 됩니다. 앱 맨 위 버전 번호(예: V1.5.6)로 확인하세요.
(아이콘을 바꾼 경우에만: 💾 기록 → 백업 → 아이콘 지우기 → 크롬에서 주소 열고 "홈 화면에 추가" → 필요하면 기록 불러오기)

## 문제가 생기면

- **"바뀐 파일이 없어요"** → 편집기에서 저장했는지, 이 폴더의 파일을 고쳤는지 확인.
- **올리기 중 오류** → 화면의 오류 메시지를 Claude에게 그대로 보여주세요.
- **사이트가 이상해졌어요** → 예전 버전으로 되돌릴 수 있어요 (모든 버전이 GitHub에 `v1.5.5` 같은 태그로 남아 있음). Claude에게 "V1.5.5로 되돌려줘"라고 말하면 됩니다.
