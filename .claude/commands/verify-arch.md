지정한 파일 또는 계층의 Clean Architecture 의존성 규칙 위반을 검사합니다.

## 규칙
| 계층 | 허용 의존 | 금지 의존 |
|---|---|---|
| Domain (`ranchat/Domain/`) | Foundation | Data, Infrastructure, Presentation |
| Data (`ranchat/Data/`) | Domain, Alamofire | Infrastructure, Presentation |
| Infrastructure (`ranchat/Infrastructure/`) | Domain(Service 프로토콜), 외부 라이브러리 | Presentation |
| Presentation (`ranchat/Presentation/`) | Domain(UseCase/Entity) | Data 직접 참조 |

## 검사 항목
1. `import` 문에서 상위 계층 참조 여부
2. 타입 참조 (DTO를 Presentation에서 직접 사용하는 등)
3. 싱글톤(`KeychainHelper.shared`, `DefaultData.shared`) 사용 위치 (Infrastructure/Presentation만 허용)
4. Repository를 ViewModel에서 직접 호출하는지 (UseCase를 통해야 함)

## 출력 형식
- 위반 없음: "규칙 위반 없음"
- 위반 있음: 파일경로:줄번호, 위반 내용, 수정 방법 제시

## 검사 대상
$ARGUMENTS
