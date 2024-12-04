import { Component, OnInit } from '@angular/core';
import { BodkinsService } from './bodkins.service'
import { Router } from '@angular/router'
import { Bodkin } from "./bodkin"
import { CommonModule, NgFor } from '@angular/common';
import { BodkinsChangedService } from './bodkins-changed.service';

@Component({
  selector: 'app-bodkins-list',
  standalone: true,
  imports: [CommonModule, NgFor],
  templateUrl: './bodkins-list.component.html',
  styleUrl: './bodkins-list.component.css',
})
export class BodkinsListComponent implements OnInit {
  bodkins: Bodkin[] = [];
  
  constructor(private service: BodkinsService, private router: Router, private changed: BodkinsChangedService) {
    this.changed.data$.subscribe(id => this.listBodkins());
  }

  ngOnInit(): void {
    this.listBodkins();
  }

  listBodkins() {
    console.log("start list bodkins from component: " + this)
    this.service.listBodkins().subscribe({
        next: (v) => {this.bodkins = [...v as Bodkin[]]; console.info("next: " + v);},
        error: (e) => console.error(e),
        complete: () => console.info("list complete (" + this.bodkins + ")"),
    });
  }
}
