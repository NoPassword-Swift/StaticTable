//
//  TextDetailViewTableCell.swift
//  StaticTable
//

#if os(iOS)

import NPKit
import UIKit

public class TextDetailViewTableCell: StaticTableCell {
	public let titleLabel = NPLabel()
	public let detailView = NPView()

	private var detailContentConstraints = [NSLayoutConstraint]()

	public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		self.contentView.addSubview(self.titleLabel)
		self.contentView.addSubview(self.detailView)

		NSLayoutConstraint.activate([
			self.titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1.5),
			self.titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2.5),
			self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.titleLabel.bottomAnchor, multiplier: 1.5),

			self.detailView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			self.detailView.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: self.titleLabel.trailingAnchor, multiplier: 1),
			self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.detailView.trailingAnchor, multiplier: 2.5),
			self.contentView.bottomAnchor.constraint(equalTo: self.detailView.bottomAnchor),
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: Set UI

	public var title: String? {
		get { self.titleLabel.text }
		set { self.titleLabel.text = newValue }
	}

	public var detail: UIView? {
		get { self.detailView.subviews.first }
		set {
			if let currentValue = self.detail {
				self.detailContentConstraints.deactivate()
				currentValue.removeFromSuperview()
			}
			if let newValue = newValue {
				self.detailView.addSubview(newValue)
				self.detailContentConstraints = newValue.fillSuperview()
				self.detailContentConstraints.activate()
			}
		}
	}
}

#endif
