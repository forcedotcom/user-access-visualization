/**
 * Copyright (c) 2012, Salesforce.com, Inc.  All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 * 
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 * 
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in
 *     the documentation and/or other materials provided with the
 *     distribution.
 * 
 *   * Neither the name of Salesforce.com nor the names of its
 *     contributors may be used to endorse or promote products derived
 *     from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
/*
 * PermsetAccessTable
 */
.permsetAccessTable {
  border-spacing: 0;
  border-collapse: collapse;
}

.permsetAccessTable thead {
  border-bottom: 1px solid black;
  vertical-align: bottom;
}

.headingContainer {
  position: relative;
}

.headingContainer .headingLabel {
  position: absolute;
  bottom: 0;
  -webkit-transform-origin: 0;
  -moz-transform-origin: 0;
  -ms-transform-origin: 0;
}

.permsetAccessTable tbody td {
  border-right: 1px solid lightgrey;
}

.permsetAccessTable tbody tr:last-child {
  border-bottom: 1px solid black;
}

.permsetAccessTable tbody tr {
  border-bottom: 1px solid lightgrey;
}

.permsetAccessTable tbody {
  border: 1px solid black;
}

.psLabel {
  padding: 0 5px 0 2px;
}

.colDisabled {
  display: none;
}

/*
 * User Perm Table, Apex Class Table, Apex Page Table
 */
.vfPageTable,
.apexClassTable,
.userPermTable {
  margin-right: 135px;
}

.vfPageTable th,
.apexClassTable th,
.userPermTable th {
  height: 150px;
  min-width: 22px;
  width: 22px;
}

.vfPageTable .headingContainer,
.apexClassTable .headingContainer,
.userPermTable .headingContainer {
  left: 10px;
  min-width: 21px;
}

.vfPageTable .headingContainer .headingLabel,
.apexClassTable .headingContainer .headingLabel,
.userPermTable .headingContainer .headingLabel {
  -webkit-transform: rotate(-34deg);
  -moz-transform: rotate(-34deg);
  -ms-transform: rotate(-34deg);
}

/*
 * Object Perm Table (and some FLS)
 */
.objectPermTable .headingContainer .headingLabel {
  -webkit-transform: rotate(-20deg);
  -moz-transform: rotate(-20deg);
  -ms-transform: rotate(-20deg);
}

.objectPermTable th {
  height: 40px;
}

.permsetAccessTable .flsDetail td,
.permsetAccessTable .objectPermDetail td {
  border: none;
  overflow: hidden;
}

.objectPermField {
  width: 8px;
}

.objectColumn:hover {
  cursor: pointer;
}

.permissionscreate_true {
  background-color: #00FF00;
}

.permissionsread_true {
  background-color: #0000FF;
}

.permissionsedit_true {
  background-color: #FFFF00;
}

.permissionsdelete_true {
  background-color: #FF0000;
}

.permissionsviewallrecords_true {
  background-color: #00FFFF;
}

.permissionsmodifyallrecords_true {
  background-color: #FF00FF;
}

/*
 * FLS
 */
.flsTableContainer {
  display: inline-block;
  margin: 0;
  padding: 0;
}

.flsTableContainerHeading {
  font-weight: bold;
  text-align: center;
  margin-bottom: 3px;
  background-color: #666666;
  color: #FFFFFF;
}

.flsTable {
  margin-right: 85px;
}

.flsTable th {
  height: 80px;
}

.flsTable .headingContainer {
  left: 7px;
}

.flsCell {
  width: 10px;
}

.flsTable .headingContainer .headingLabel {
  -webkit-transform: rotate(-35deg);
  -moz-transform: rotate(-35deg);
  -ms-transform: rotate(-35deg);
  width: 120px;
  overflow: hidden;
  text-overflow: ellipsis;
}

/*
 * Misc
 */
.nowrap {
  white-space: nowrap;
}

.border-right {
  border-right: 1px solid black;
}