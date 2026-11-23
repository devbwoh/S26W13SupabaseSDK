import SwiftUI
import Supabase

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Button("홍길동(gdhong) 로그인") {
                Task {
                    await signInTestUser()
                }
            }
            .buttonStyle(.borderedProminent)

            Button("노래 목록 콘솔 출력") {
                Task {
                    await fetchSongsTest()
                }
            }
            .buttonStyle(.bordered)
            
            Button("로그아웃") {
                Task {
                    await signOutTestUser()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    func signInTestUser() async {
        do {
            let session = try await SupabaseManager.client.auth.signIn(
                email: "gdhong@test.com",
                password: "pass123"
            )
            print("로그인 성공! User ID: \(session.user.id)")
        } catch {
            print("로그인 에러: \(error.localizedDescription)")
        }
    }

    func fetchSongsTest() async {
        do {
            let response = try await SupabaseManager.client
                .from("songs")
                .select()
                .execute()

            let jsonString = String(data: response.data, encoding: .utf8) ?? "데이터 없음"
            print("조회 결과:\n\(jsonString)")
        } catch {
            print("조회 에러: \(error.localizedDescription)")
        }
    }
    
    func signOutTestUser() async {
        do {
            try await SupabaseManager.client.auth.signOut()
            print("로그아웃 성공")
        } catch {
            print("로그아웃 에러: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ContentView()
}
