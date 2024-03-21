//
//  File.swift
//  idwall_sdk
//
//  Created by Sergio Costa on 22/05/23.
//
import Foundation
import IDwallToolkit

class HelperFunctions{
    static let sharedInstance = HelperFunctions()
    
    private init () {}

    func asDocumentType(type: String?) -> IDDocumentType? {
        switch type {
        case "rg":
            return .RG
        case "cnh":
            return .CNH
        case "crlv":
            return .CRLV
        case "rne":
            return .RNE
        case "crnm":
            return .CRNM
        default:
            return nil
        }
    }

    func asDocumentSide(side: String?) -> IDDocSide? {
        switch side {
        case "front":
            return .Front
        case "back":
            return .Back
        default:
            return nil
        }
    }
    
    func asFlowType(flow: String?) -> IDFlowType? {
        switch flow {
        case "complete":
            print(flow as Any);
            return IDFlowType.Complete
        case "liveness":
            return IDFlowType.Liveness
        case "document":
            return IDFlowType.Document
        default:
            return nil
        }
    }
    
    func asSendType(send: String?) -> IDWallSend? {
        switch send {
        case "all":
            return .All
        case "liveness":
            return .Liveness
        case "document":
            return .Document
        default:
            return nil
        }
    }
    
    func asIDDocInputType(input: String?) -> IDDocInputType? {
        switch input {
        case "printed":
            return .Printed
        case "digital":
            return .Digital
        default:
            return nil
        }
    }

    func asLogginLevel(any: String?) -> IDLoggingLevel? {
        switch any {
        case "verbose":
            return .Verbose
        case "minimal":
            return .Minimal
        case "regular":
            return .Regular
        default:
            return nil
        }
    }
}
