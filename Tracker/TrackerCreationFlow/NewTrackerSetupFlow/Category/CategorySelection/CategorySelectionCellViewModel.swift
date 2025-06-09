//
//  CategorySelectionCellViewModel.swift
//  Tracker
//
//  Created by Vladimir on 09.06.2025.
//

final class CategorySelectionCellViewModel {
    var cellModel: CategorySelectionCellModel {
        didSet {
            onCellModelChange?(cellModel)
        }
    }
    var onCellModelChange: Binding<CategorySelectionCellModel>? {
        didSet {
            onCellModelChange?(cellModel)
        }
    }
    
    init(cellModel: CategorySelectionCellModel) {
        self.cellModel = cellModel
    }
}
