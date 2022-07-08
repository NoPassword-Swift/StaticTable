//
//  ButtonTableCell.swift
//  StaticTable
//

#if os(iOS)

import Color
import NPKit
import UIKit

public class ButtonTableCell: StaticTableCell {
	public let titleLabel: NPLabel = {
		let view = NPLabel()
		view.textAlignment = .center
		return view
	}()

	public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		self.contentView.addSubview(self.titleLabel)

		NSLayoutConstraint.activate([
			self.titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1.5),
			self.titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2.5),
			self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.titleLabel.trailingAnchor, multiplier: 2.5),
			self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.titleLabel.bottomAnchor, multiplier: 1.5),
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public override func prepareForReuse() {
		super.prepareForReuse()
		self.setDestructive(false)
	}

	// MARK: Set UI

	public var title: String? {
		get { self.titleLabel.text }
		set { self.titleLabel.text = newValue }
	}

	public func setDestructive(_ isDestructive: Bool) {
		if isDestructive {
			self.titleLabel.textColor = Color.systemRed
		} else {
			self.titleLabel.textColor = Color.label
		}
	}
}

#endif
