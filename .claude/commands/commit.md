변경 사항을 분석해서 프로젝트 규칙에 맞는 커밋을 생성합니다.

## 규칙
- 커밋 메시지 형식: `[type] 한국어 설명`
- type: `feat` / `fix` / `refactor` / `chore` / `docs` / `test`
- `Co-Authored-By` 절대 포함 금지
- 변경 내용이 명확하게 드러나는 간결한 메시지 사용

## 절차
1. `git status`와 `git diff`로 변경 사항 파악
2. 변경의 성격에 맞는 type 선택
3. 관련 파일만 `git add`
4. 커밋 생성 (HEREDOC 사용)

$ARGUMENTS
