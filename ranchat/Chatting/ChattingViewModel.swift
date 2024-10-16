//
//  ChattingViewModel.swift
//  ranchat
//
//  Created by 김견 on 10/9/24.
//

import Foundation

@Observable
class ChattingViewModel {
    var chattingList: [MessageData] = [
        MessageData(id: 1, content: "안녕"),
        MessageData(id: 2, content: "ㅎㅇ"),
        MessageData(id: 3, content: "바이"),
        MessageData(id: 4, content: "룰루"),
        MessageData(id: 5, content: "트리스타나"),
        MessageData(id: 6, content: "이즈리얼"),
        MessageData(id: 7, content: "브라움"),
        MessageData(id: 8, content: "소라카"),
        MessageData(id: 9, content: "미스포츈"),
        MessageData(id: 10, content: "케이틀린"),
        MessageData(id: 11, content: "진"),
        MessageData(id: 12, content: "드레이븐"),
        MessageData(id: 13, content: "벡스"),
        MessageData(id: 14, content: "모데카이저"),
        MessageData(id: 15, content: "아우렐리온 솔"),
        MessageData(id: 16, content: "모르가나"),
        MessageData(id: 17, content: "요네"),
        MessageData(id: 18, content: "야스오"),
        MessageData(id: 19, content: "아트록스"),
        MessageData(id: 20, content: "일라오이"),
        MessageData(id: 21, content: "오공"),
        MessageData(id: 22, content: "자르반"),
        MessageData(id: 23, content: "피들스틱"),
        MessageData(id: 24, content: "자야"),
        MessageData(id: 25, content: "라칸"),
        MessageData(id: 26, content: "블리츠크랭크"),
        MessageData(id: 27, content: "쓰레쉬"),
        MessageData(id: 28, content: "레오나"),
        MessageData(id: 29, content: "베이가"),
    ]
    var isLoading: Bool = false
    
    var inputText: String = ""
    var roomDetailData: RoomDetailData?
    
    var showReportDialog: Bool = false
    var showExitDialog: Bool = false
    
    var selectedReason: String?
    var reportText: String = ""
    
    func reportUser() {
        
    }
    
    func exitRoom() async {
        isLoading = true
        
        
        
        isLoading = false
    }
}
