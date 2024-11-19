//
//  DB.swift
//  Swift_ASP
//
//  Created by ZH Chen on 2024/11/18.
//

import Foundation
import CloudKit

let lostItemsDatabase = CKContainer.default().publicCloudDatabase
let locationDatabase = CKContainer.default().privateCloudDatabase
let userDatabase = CKContainer.default().privateCloudDatabase

// Create Lost items records
private func lostItemsRecords(of type: String, completion: @escaping (Result<[CKRecord], Error>) -> Void) {
    let newRecord = CKRecord(recordType: "LostItems")
    newRecord["LostItems"] = "value" as CKRecordValue
    
    lostItemsDatabase.save(newRecord) { (record, error) in
        if let error = error {
            print("Error saving record: \(error)")
        } else {
            print("Record saved successfully.")
        }
    }
}

// Create location records
private func locationRecords(of type: String, completion: @escaping (Result<[CKRecord], Error>) -> Void) {
    let newRecord = CKRecord(recordType: "Location")
    newRecord["Location"] = "value" as CKRecordValue
    
    locationDatabase.save(newRecord) { (record, error) in
        if let error = error {
            print("Error saving record: \(error)")
        } else {
            print("Record saved successfully.")
        }
    }
}

// Create user infomation records
private func userRecords(of type: String, completion: @escaping (Result<[CKRecord], Error>) -> Void) {
    let newRecord = CKRecord(recordType: "User")
    newRecord["User"] = "value" as CKRecordValue
    
    userDatabase.save(newRecord) { (record, error) in
        if let error = error {
            print("Error saving record: \(error)")
        } else {
            print("Record saved successfully.")
        }
    }
}

// Reading lost items records
private func readLostItemsRecords(of type: String, completion: @escaping (Result<[CKRecord], Error>) -> Void) {
    let query = CKQuery(recordType: "LostItems", predicate: NSPredicate(value: true))
    lostItemsDatabase.perform(query, inZoneWith: nil) { (records, error) in
        if let error = error {
            print("Error fetching records: \(error)")
        } else {
            print("Fetched records: \(String(describing: records))")
        }
    }
}

// Reading location records
private func readLocationRecords(of type: String, completion: @escaping (Result<[CKRecord], Error>) -> Void) {
    let query = CKQuery(recordType: "Location", predicate: NSPredicate(value: true))
    locationDatabase.perform(query, inZoneWith: nil) { (records, error) in
        if let error = error {
            print("Error fetching records: \(error)")
        } else {
            print("Fetched records: \(String(describing: records))")
        }
    }
}

// Reading user records
private func readUserRecords(of type: String, completion: @escaping (Result<[CKRecord], Error>) -> Void) {
    let query = CKQuery(recordType: "User", predicate: NSPredicate(value: true))
    userDatabase.perform(query, inZoneWith: nil) { (records, error) in
        if let error = error {
            print("Error fetching records: \(error)")
        } else {
            print("Fetched records: \(String(describing: records))")
        }
    }
}


