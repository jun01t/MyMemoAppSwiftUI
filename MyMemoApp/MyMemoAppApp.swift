import SwiftUI

// MARK: MemoListView
struct MemoListView: View {
    @ObservedObject var viewModel = MemoViewModel()
    
    @State private var isMemoTextFieldPresented = false
    @State private var isDeleteAlertPresented = false
    @State private var isDeleteAllAlertPresented = false
    @State private var memoTextField = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if (isMemoTextFieldPresented) {
                    TextField("メモを入力してください", text: $memoTextField)
                        .textFieldStyle(DefaultTextFieldStyle())
                        .keyboardType(.default)
                }
                List {
                    ForEach(viewModel.memos.sorted {
                        $0.postedDate > $1.postedDate
                    }) { memo in
                        HStack {
                            MemoRowView(memo: memo)
                            Spacer()
                            // Buttonにすると行全体にタップ判定がついてしまったので、Text.onTapGestureを代わりに使っている
                            Text("削除").onTapGesture {
                                isDeleteAlertPresented.toggle()
                            }
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.red)
                        }
                        .alert(isPresented: $isDeleteAlertPresented) {
                            Alert(title: Text("警告"),
                                  message: Text("メモを削除します。\nよろしいですか？"),
                                  primaryButton: .cancel(Text("いいえ")),
                                  secondaryButton: .destructive(Text("はい")) {
                                    viewModel.deleteMemo = memo
                                  }
                            )
                        }
                    }
                }
            }
            .navigationTitle("メモの一覧")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("全削除") {
                        isDeleteAllAlertPresented.toggle()
                    }
                    .disabled(viewModel.memos.isEmpty)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("追加") {
                        if (isMemoTextFieldPresented) {
                            viewModel.memoTextField = memoTextField
                            memoTextField = ""
                        }
                        isMemoTextFieldPresented.toggle()
                    }.disabled(isMemoTextFieldPresented && memoTextField.isEmpty)
                }
            }
            .alert(isPresented: $isDeleteAllAlertPresented) {
                Alert(title: Text("警告"),
                      message: Text("全てのメモを削除します。\nよろしいですか？"),
                      primaryButton: .cancel(Text("いいえ")),
                      secondaryButton: .destructive(Text("はい")) {
                        viewModel.isDeleteAllTapped = true
                      }
                )
            }
        }
    }
}

// MARK: MemoRowView
struct MemoRowView: View {
    var memo: Memo
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(formatDate(memo.postedDate))
                .font(.caption)
                .fontWeight(.bold)
            Text(memo.text)
                .font(.body)
        }
    }
    
    func formatDate(_ date : Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .medium
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}
