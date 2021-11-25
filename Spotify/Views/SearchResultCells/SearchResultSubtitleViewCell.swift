//
//  SearchResultSubtitleViewCell.swift
//  Spotify
//
//  Created by Ali Hammoud on 11/25/21.
//

import UIKit
import SDWebImage

class SearchResultSubtitleViewCell: UITableViewCell {

    static let identifier = "SearchResultSubtitleViewCell"
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    private let subtTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(subtTitleLabel)
        contentView.addSubview(iconImageView)
        contentView.clipsToBounds = true
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = contentView.height-10
        iconImageView.frame = CGRect(x: 10, y: 5, width: imageSize, height: imageSize)
        let labelHeight = contentView.height/2
        label.frame = CGRect(
            x: iconImageView.right+10,
            y: 0,
            width: contentView.width-iconImageView.right-15,
            height: labelHeight
        )
        
        subtTitleLabel.frame = CGRect(
            x: iconImageView.right+10,
            y: label.bottom,
            width: contentView.width-iconImageView.right-15,
            height: labelHeight
        )
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        label.text = nil
        subtTitleLabel.text = nil
    }
    
    func configre(with viewModel: SearchResultSubtitleViewCellViewModel) {
        label.text = viewModel.title
        subtTitleLabel.text = viewModel.subtitle
        iconImageView.sd_setImage(with: viewModel.imageURL, completed: nil)
        
    }
}

