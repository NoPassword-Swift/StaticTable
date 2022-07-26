//
//  DataTableController.swift
//  StaticTable
//

#if os(iOS)

import CoreCombine
import NPCombine
import UIKit

open class DataTableController: TableController {
	public private(set) lazy var data: TableData = TableData(tableView: self.tableView as! TableView)

	public var enableAPI: CBSubject<Bool>?
	public var breakAPI: CBSubject<Bool>?

	open override func tableView(_ tableView: TableView, cellForRowAt indexPath: IndexPath) -> TableCell {
		let row = self.data[indexPath]
		switch row.kind {
			case .text:
				let cell = tableView.dequeueText(for: indexPath)
				switch row.name {
					case .none: cell.title = " "
					case let .string(name): cell.title = name
				}
				return cell
			case let .value(value):
				let cell = tableView.dequeueValue(for: indexPath)
				switch row.name {
					case .none: cell.title = " "
					case let .string(name): cell.title = name
				}
				switch value {
					case .none: cell.value = " "
					case let .string(value): cell.value = value
				}
				return cell
			case let .secretValue(secret):
				let cell = tableView.dequeueSecretValue(for: indexPath)
				cell.updateSettings(enableAPI: self.enableAPI, breakAPI: self.breakAPI)
				switch row.name {
					case .none: cell.title = " "
					case let .string(name): cell.title = name
				}
				if row.options.contains(.copyable) && tableView.indexPathForSelectedRow == indexPath {
					cell.secret = secret()
				} else {
					cell.secret = nil
				}
				return cell
			case .button:
				let cell = tableView.dequeueText(for: indexPath)
				switch row.name {
					case .none: cell.title = " "
					case let .string(name): cell.title = name
				}
				if row.options.contains(.destructive) {
					cell.setStatus(.destructive)
				} else if row.options.contains(.highlighed) {
					cell.setStatus(.hightlighted)
				}
				cell.alignment = .center
				return cell
			case let .toggle(subject):
				let cell = tableView.dequeueToggle(for: indexPath)
				switch row.name {
					case .none: cell.title = " "
					case let .string(name): cell.title = name
				}
				cell.trackToggle(to: subject)
				return cell
			case let .textField(placeholder, subject):
				let cell = tableView.dequeueTextField(for: indexPath)
				switch row.name {
					case .none: cell.title = " "
					case let .string(name): cell.title = name
				}
				switch placeholder {
					case .none: cell.placeholder = nil
					case let .string(placeholder): cell.placeholder = placeholder
				}
				cell.trackTextField(to: subject)
				return cell
			case let .secretTextField(placeholder, subject):
				let cell = tableView.dequeueTextField(for: indexPath)
				switch row.name {
					case .none: cell.title = " "
					case let .string(name): cell.title = name
				}
				switch placeholder {
					case .none: cell.placeholder = nil
					case let .string(placeholder): cell.placeholder = placeholder
				}
				cell.isSecure = true
				cell.trackTextField(to: subject)
				return cell
			case .menu:
				let cell = tableView.dequeueText(for: indexPath)
				switch row.name {
					case .none: cell.title = " "
					case let .string(name): cell.title = name
				}
				if row.options.contains(.destructive) {
					cell.setStatus(.destructive)
				} else if row.options.contains(.highlighed) {
					cell.setStatus(.hightlighted)
				}
				cell.accessoryType = .disclosureIndicator
				return cell
			case let .picker(subject, pickerType):
				let cell = tableView.dequeueButton(for: indexPath)
				switch row.name {
					case .none: cell.title = " "
					case let .string(name): cell.title = name
				}
				cell.bindButtonText(to: subject.map { pickerType.init(rawValue: $0)?.localizedDescription ?? "" })
				cell.buttonAction {
					let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
					for item in pickerType.allCases {
						alert.addAction(UIAlertAction(title: item.localizedDescription, style: .default, handler: { _ in
							subject.send(item.rawValue)
						}))
					}
					alert.addAction(UIAlertAction(title: NSLocalizedString("localized.menu.cancel", comment: ""), style: .cancel))
					self.present(alert, animated: true)
				}
				return cell
			case let .iconSubtitle(icon, subtitle):
				let cell = tableView.dequeueIconSubtitle(for: indexPath)
				cell.icon = icon
				switch row.name {
					case .none: cell.title = " "
					case let .string(name): cell.title = name
				}
				switch subtitle {
					case .none: cell.subtitle = " "
					case let .string(subtitle): cell.subtitle = subtitle
				}
				return cell
			case let .largeIconSubtitle(icon, subtitle):
				let cell = tableView.dequeueLargeIconSubtitle(for: indexPath)
				cell.icon = icon
				switch row.name {
					case .none: cell.title = " "
					case let .string(name): cell.title = name
				}
				switch subtitle {
					case .none: cell.subtitle = " "
					case let .string(subtitle): cell.subtitle = subtitle
				}
				return cell
		}
	}
}

// MARK: UITableViewDataSource
extension DataTableController {
	public override func numberOfSections(in tableView: UITableView) -> Int { self.data.numberOfSections }

	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { self.data[section].numberOfRows }

	public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch self.data[section].header {
			case .none: return nil
			case let .string(name): return name
		}
	}

	public override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		switch self.data[section].footer {
			case .none: return nil
			case let .string(name): return name
		}
	}
}

// MARK: UITableViewDelegate
extension DataTableController {
	public override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		let row = self.data[indexPath]
		switch row.kind {
			case .button, .menu:
				return true
			default:
				return row.options.contains(.selectable)
		}
	}

	public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let row = self.data[indexPath]
		switch row.kind {
			case let .button(action):
				tableView.deselectRow(at: indexPath, animated: true)
				action()
			case let .menu(factory):
				self.navigationController?.pushViewController(factory(), animated: true)
			default:
				tableView.deselectRow(at: indexPath, animated: true)
		}
	}
}

#endif
