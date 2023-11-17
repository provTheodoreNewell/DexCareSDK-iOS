// Copyright © 2019 Providence. All rights reserved.

import Foundation

struct VisitSummary: Decodable, Equatable {
    let visitId: String
    let userId: String
    let status: VisitStatus
    let tokBoxVisit: TokBoxVisit?
    let tytoCare: TytoCareResponse
    
    // v9
    let modality: VirtualVisitModality? // should be not optional on v9 visits. But if looking up old visits, will be null
    
    enum CodingKeys: String, CodingKey {
        case visitId
        case userId
        case status
        case isTokBox
        case tokBoxVisit
        case integrations
        case tytoCare
        case modality
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
         
        visitId = try container.decode(String.self, forKey: .visitId)
        userId = try container.decode(String.self, forKey: .userId)
        status = try container.decode(VisitStatus.self, forKey: .status)
        tokBoxVisit = try? container.decode(TokBoxVisit.self, forKey: .tokBoxVisit)
        
        let integrationContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .integrations)
        tytoCare = try integrationContainer.decode(TytoCareResponse.self, forKey: .tytoCare)
        
        // v9
        if let modalityString = try? container.decode(String.self, forKey: .modality) {
            modality = VirtualVisitModality(rawValue: modalityString)
        } else {
            modality = nil
        }
    }

    init(
        visitId: String,
        userId: String,
        status: VisitStatus,
        tokBoxVisit: TokBoxVisit?,
        tytoCare: TytoCareResponse,
        modality: VirtualVisitModality?
    ) {
        self.visitId = visitId
        self.userId = userId
        self.status = status
        self.tokBoxVisit = tokBoxVisit
        self.tytoCare = tytoCare
        self.modality = modality
    }
}

/// A status of a Virtual Visit
/// A `RawRepresentable` structure representing the status a visit could have
/// - Note: A `VisitStatus` in this context is simply a `String`. You can exchange a `VisitStatus` with a string without issue.
///
public enum VisitStatus: String, Codable, Equatable {
    /// visit has been requested
    case requested = "requested"
    
    /// visit is in the waiting room
    case waitingRoom = "waitingroom"
    @available(*, unavailable, renamed: "waitingRoom")
    case waitingroom = "old waitingroom"
    
    /// visit is currently in a virtual visit
    case inVisit = "invisit"
    @available(*, unavailable, renamed: "inVisit")
    case invisit = "old invisit"
    
    /// visit has completed
    case done = "done"
    
    /// visit was cancelled
    case cancelled = "cancelled"
    
    /// visit was declined by the staff before seeing a provider
    case staffDeclined = "staffdeclined"
    @available(*, unavailable, renamed: "staffDeclined")
    case staffdeclined = "old staffdeclined"
    
    /// A helper function to tell you whether or not a visit is classified as expired.
    /// - Note: When this is true, you must start a new virtual visit and cannot resume. 
    public func isActive() -> Bool {
        switch self {
        case .done, .cancelled, .staffDeclined:
            return false
        case .requested, .inVisit, .waitingRoom:
            return true
        }
    }
}

struct TokBoxTokenResponse: Decodable, Equatable {
    let token: String
}

struct TytoCareResponse: Decodable, Equatable {
    let enabled: Bool
}
