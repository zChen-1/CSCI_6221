//
//  lostItems_cloud.h
//  Swift_ASP
//
//  Created by ZH Chen on 2024/11/18.
//

#ifndef lostItems_cloud_h
#define lostItems_cloud_h
import CloudKit

func saveLostItemsToCloudKit(lostItems: [LostItems]) {
    let container = CKContainer.default()
    let privateDatabase = container.privateCloudDatabase

    for item in lostItems {
        let record = CKRecord(recordType: "LostItem")
        record["name"] = item.name as CKRecordValue
        record["itemType"] = item.itemType as CKRecordValue
        record["itemDescription"] = item.itemDescription as CKRecordValue
        record["locationID"] = item.locationID as CKRecordValue
        record["imageName"] = item.imageName as CKRecordValue

        privateDatabase.save(record) { (record, error) in
            if let error = error {
                print("Error saving record: \(error)")
            } else {
                print("Lost Item saved successfully: \(String(describing: record))")
            }
        }
    }
}

func fetchLostItemsFromCloudKit() {
    let container = CKContainer.default()
    let privateDatabase = container.privateCloudDatabase
    let query = CKQuery(recordType: "LostItem", predicate: NSPredicate(value: true))

    privateDatabase.perform(query, inZoneWith: nil) { (records, error) in
        if let error = error {
            print("Error fetching records: \(error)")
            return
        }

        if let records = records {
            for record in records {
                guard let name = record["name"] as? String,
                      let itemType = record["itemType"] as? String,
                      let itemDescription = record["itemDescription"] as? String,
                      let locationID = record["locationID"] as? Int,
                      let imageName = record["imageName"] as? String else { continue }

                let lostItem = LostItems(name: name, itemType: itemType, itemDescription: itemDescription, locationID: locationID, imageName: imageName)
                print("Fetched Lost Item: \(lostItem)")
            }
        }
    }
}

#endif /* lostItems_cloud_h */
