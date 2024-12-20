	
import Foundation

class TaskManager: ObservableObject {
    static let shared = TaskManager()
    
    @Published private var completedTasks: Set<String> = []
    
    func toggleTask(_ task: String) {
        if completedTasks.contains(task) {
            completedTasks.remove(task)
        } else {
            completedTasks.insert(task)
        }
    }
    
    func isTaskCompleted(_ task: String) -> Bool {
        completedTasks.contains(task)
    }
}
