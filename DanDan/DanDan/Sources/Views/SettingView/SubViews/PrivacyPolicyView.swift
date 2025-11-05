//
//  PrivacyPolicyView.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/5/25.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 제목
            Text("개인정보 처리방침 [스틸워크]")
                .font(.PR.title1)
                .foregroundColor(.steelBlack)
                .padding(.top, 45)
                .padding(.bottom, 8)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("업데이트 날짜: 2025년 11월")
                        .font(.PR.caption3)
                        .foregroundColor(.gray3)
//                        .padding(.top, 8)
                    
                    Text("""
                    [스틸워크](이하 ‘본 앱’)은 현재 사용자의 개인정보를 수집하지 않습니다. 본 앱은 사용자의 개인정보 보호를 매우 중요하게 여기며, 아래와 같이 개인정보처리방침을 안내드립니다.
                    """)
                    .font(.PR.caption2)
                    .foregroundColor(.gray1)
                    .padding(.vertical, 16)
                        
                    Group {
                        VStack(alignment: .leading, spacing: 12){
                            // 1. 수집 및 이용
                            Text("1. 개인정보 수집 및 이용")
                                .font(.PR.body2)
                                .foregroundColor(.steelBlack)
                            
                            
                            Text("본 앱은 이름, 연락처, 이메일, 위치 정보 등 개인을 식별할 수 있는 어떠한 정보도 수집하지 않습니다.")
                                .font(.PR.caption2)
                                .foregroundColor(.gray1)
                                .padding(.bottom, 12)
                            
                            // 2. 제3자 제공 및 외부 서비스
                            Text("2. 제3자 제공 및 외부 서비스")
                                .font(.PR.body2)
                                .foregroundColor(.steelBlack)
                            
                            Text("본 앱은 외부 서버 또는 제3자 서비스와 정보를 공유하지 않으며, Google Analytics, Firebase 등의 분석 도구도 사용하지 않습니다.")
                                .font(.PR.caption2)
                                .foregroundColor(.gray1)
                                .padding(.bottom, 12)
                            
                            // 3. 보유 및 이용 기간
                            Text("3. 보유 및 이용 기간")
                                .font(.PR.body2)
                                .foregroundColor(.steelBlack)
                                
                            
                            Text("현재 개인정보를 수집하지 않기 때문에 보관하거나 사용하는 정보가 없습니다.")
                                .font(.PR.caption2)
                                .foregroundColor(.gray1)
                                .padding(.bottom, 12)
                            
                            // 4. 사용자 권리
                            Text("4. 사용자 권리")
                                .font(.PR.body2)
                                .foregroundColor(.steelBlack)
                            
                            Text("개인정보를 수집하지 않기 때문에 별도의 열람, 수정, 삭제 요청은 필요하지 않습니다.")
                                .font(.PR.caption2)
                                .foregroundColor(.gray1)
                                .padding(.bottom, 12)
                            
                            // 5. 정책 변경 안내
                            Text("5. 정책 변경 안내")
                                .font(.PR.body2)
                                .foregroundColor(.steelBlack)
                            
                            Text("""
                        본 앱은 현재 개인정보를 수집하지 않지만, 향후 기능 확장 또는 서비스 개선 과정에서 사용자 정보를 수집하게 될 가능성이 있습니다.
                        추후 개인정보를 수집하게 될 경우, 사용자에게 명확한 사전 동의를 받고, 본 방침을 업데이트하여 앱 내 공지 또는 이메일을 통해 안내드리겠습니다.
                        """)
                            .font(.PR.caption2)
                            .foregroundColor(.gray1)
                            .padding(.bottom, 12)
                            
                            // 6. 문의처
                            Text("6. 문의처")
                                .font(.PR.body2)
                                .foregroundColor(.steelBlack)
                            Text("""
                        문의사항이 있으시면 아래 이메일로 연락해 주세요.
                        📧 duilwang@naver.com
                        """)
                            .font(.PR.caption2)
                            .foregroundColor(.gray1)
                            .padding(.bottom, 12)
                        }
                    }
                }
            }

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }
}

#Preview {
    PrivacyPolicyView()
}
