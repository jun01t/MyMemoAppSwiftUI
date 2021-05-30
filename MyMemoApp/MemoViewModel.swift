import Foundation
import Combine

class MemoViewModel: ObservableObject {
    
    @Published private(set) var memos: [Memo] = Array(Memo.findAll())
    @Published var memoTextField = ""
    @Published var deleteMemo: Memo?
    @Published var isDeleteAllTapped = false
    
    private var addMemoTask: AnyCancellable?
    private var deleteMemoTask: AnyCancellable?
    private var deleteAllMemoTask: AnyCancellable?
    
    init() {
        addMemoTask = self.$memoTextField
            .sink() { text in
                guard !text.isEmpty else {
                    return
                }
                let memo = Memo()
                memo.text = text
                self.memos.append(memo)
                Memo.add(memo)
            }
        deleteMemoTask = self.$deleteMemo
            .sink() { memo in
                guard let memo = memo else {
                    return
                }
                if let index = self.memos.firstIndex(of: memo) {
                    self.memos.remove(at: index)
                    Memo.delete(memo)
                }
            }
        deleteAllMemoTask = self.$isDeleteAllTapped
            .sink() { isDeleteAllTapped in
                if (isDeleteAllTapped) {
                    Memo.delete(self.memos)
                    self.memos.removeAll()
                    self.isDeleteAllTapped = false
                }
            }
    }
}
