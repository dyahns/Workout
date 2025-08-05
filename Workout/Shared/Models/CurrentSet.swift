struct CurrentSet {
    let id: Int?
    let input: InputField?
    
    enum InputField: Equatable {
        case weight
        case reps
    }
}


