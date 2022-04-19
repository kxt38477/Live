import Foundation

// MARK: - TopLevel
struct TopLevel: Codable {
    let event, room_id: String?
    let sender_role: Int?
    let body: RoomsInfo?
    let time: String?
}

// MARK: - Body
struct RoomsInfo: Codable {
    let chat_id, account, nickname, recipient: String?
    let type, text, accept_time: String?
    let info: Info?
    let entry_notice: EntryNotice?
    let room_count, real_count: Int?
    let guardian_count, guardian_sum, contribute_sum: Int?
    let content: Content?
}

// MARK: - Content
struct Content: Codable {
    let cn, en, tw: String?
}

// MARK: - EntryNotice
struct EntryNotice: Codable {
    let username, head_photo, action: String?
}


// MARK: - Info
struct Info: Codable {
    let last_login, is_ban, level, is_guardian: Int?
    let badges: Bool?
}


