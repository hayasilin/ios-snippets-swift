import UIKit

// Other great Codable aritcle reference
// 現實使用 Codable 上遇到的 Decode 問題場景總匯
// https://medium.com/zrealm-ios-dev/%E7%8F%BE%E5%AF%A6%E4%BD%BF%E7%94%A8-codable-%E4%B8%8A%E9%81%87%E5%88%B0%E7%9A%84-decode-%E5%95%8F%E9%A1%8C%E5%A0%B4%E6%99%AF%E7%B8%BD%E5%8C%AF-1aa2f8445642
// https://zhgchgli.medium.com/%E7%8F%BE%E5%AF%A6%E4%BD%BF%E7%94%A8-codable-%E4%B8%8A%E9%81%87%E5%88%B0%E7%9A%84-decode-%E5%95%8F%E9%A1%8C%E5%A0%B4%E6%99%AF%E7%B8%BD%E5%8C%AF-%E4%B8%8B-cb00b1977537

struct Payload: Encodable {
    let title: String
    let limit: Int
    let isNew: Bool
    let imageUrl: URL
}

let payload = Payload(title: "test", limit: 1,isNew: true, imageUrl: URL(fileURLWithPath: ""))

let urlString = "https://example.com"
let url = URL(string: urlString)!
var urlRequest = URLRequest(url: url)
urlRequest.httpMethod = "POST"
urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")

// Encode JSON data
urlRequest.httpBody = try? JSONEncoder().encode(payload)

func getData<T: Decodable>(completion: @escaping (T?, Error?) -> Void) {
    URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
        guard let data = data else {
            completion(nil, error)
            return
        }

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            completion(nil, error)
            return
        }

        // Before Swift 4 to decode JSON data
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return
        }
        print(json)

        // After Swift 4 to decode JSON data
        let decodedJson = try? JSONDecoder().decode(T.self, from: data)
        completion(decodedJson, nil)

    }.resume()
}

// Complex api json response sample
struct DemoResponse: Codable {
    let titleLabel: Label
    let sections: [Section]

    struct Section: Codable {
        let items: [Item]

        struct Item: Codable {
            var badge: Badge?
            var imageUrl: String
            var itemType: ItemType?
            var primaryLabel: Label
            var secondaryLabel: Label?
            var tertiaryLabel: Label?
            var url: String

            public struct Badge: Codable {
                public let label: Label?
                public let iconUrl: String?
            }

            public enum ItemType: String, Codable {
                case voucher
                case coupon
            }

            public init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                let itemTypeStringResponse = try values.decodeIfPresent(String.self, forKey: .itemType)
                if let itemTypeString = itemTypeStringResponse {
                    itemType = ItemType(rawValue: itemTypeString) ?? .voucher
                }

                badge = try values.decodeIfPresent(Badge.self, forKey: .badge)
                imageUrl = try values.decode(String.self, forKey: .imageUrl)
                primaryLabel = try values.decode(Label.self, forKey: .primaryLabel)
                secondaryLabel = try values.decodeIfPresent(Label.self, forKey: .secondaryLabel)
                tertiaryLabel = try values.decodeIfPresent(Label.self, forKey: .tertiaryLabel)
                url = try values.decode(String.self, forKey: .url)
            }
        }
    }

    public struct Label: Codable {
        public let text: String
        public let color: String?
        public let style: String?
    }
}

// JSON encoder, decoder, and JSONSerialization sample
struct Tutorial: Codable {
    let title: String!
    let author: String!
    let editor: String!
    let type: String!
    let publishDate: Date!
}

let tutorial = Tutorial(title: "Swift4", author: "Lin", editor: "Kuan", type: "Swift", publishDate: Date())

// Make object it to JSON data
let jsonData = try? JSONEncoder().encode(tutorial)
print("jsonData = \(String(describing: jsonData))")

// Make JSON data back to string
let jsonString = String(data: jsonData!, encoding: .utf8)
print("jsonString = \(String(describing: jsonString))")

let jsonSerializationResult = try? JSONSerialization.jsonObject(with: jsonData!) as? [String: Any]
print("jsonSerializationResult = \(String(describing: jsonSerializationResult))")

// Decode JSON data
let article = try? JSONDecoder().decode(Tutorial.self, from: jsonData!)
let info = "\(String(describing: article?.title)) \(String(describing: article?.author)) \(String(describing: article?.editor)) \(String(describing: article?.type)) \(String(describing: article?.publishDate))"
print("info = \(info)")


// Use CodingKeys example
struct Feature: Codable {
    let feature: [Gourmet]

    private enum CodingKeys: String, CodingKey {
        case feature = "Feature"
    }
}

struct Geometry: Codable {
    let type: String
    let coordinates: String

    private enum CodingKeys: String, CodingKey {
        case type = "Type"
        case coordinates = "Coordinates"
    }
}

struct Property: Codable {
    let address: String
    let tel: String
    let leadImage: String
    let yomi: String

    private enum CodingKeys: String, CodingKey {
        case address = "Address"
        case tel = "Tel1"
        case leadImage = "LeadImage"
        case yomi = "Yomi"
    }
}

struct Gourmet: Codable {
    let gid: String
    let name: String
    let geometry: Geometry
    let property: Property

    private enum CodingKeys: String, CodingKey {
        case gid = "Gid"
        case name = "Name"
        case geometry = "Geometry"
        case property = "Property"
    }
}
