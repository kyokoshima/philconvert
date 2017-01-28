//
//  CollectionViewCell.swift
//  philconvert
//
//  Created by 横島健一 on 2017/01/24.
//  Copyright © 2017年 info.tmpla. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var rate: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var amount: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
