/*
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* Automatically generated nanopb header */
/* Generated by nanopb-0.3.9.8 */

#ifndef PB_FIRESTORE_BUNDLE_NANOPB_H_INCLUDED
#define PB_FIRESTORE_BUNDLE_NANOPB_H_INCLUDED
#include <pb.h>

#include "google/firestore/v1/document.nanopb.h"

#include "google/firestore/v1/query.nanopb.h"

#include "google/protobuf/timestamp.nanopb.h"

#include <string>

namespace firebase {
namespace firestore {

/* @@protoc_insertion_point(includes) */
#if PB_PROTO_HEADER_VERSION != 30
#error Regenerate this file with the current version of nanopb generator.
#endif


/* Enum definitions */
typedef enum _firestore_BundledQuery_LimitType {
    firestore_BundledQuery_LimitType_FIRST = 0,
    firestore_BundledQuery_LimitType_LAST = 1
} firestore_BundledQuery_LimitType;
#define _firestore_BundledQuery_LimitType_MIN firestore_BundledQuery_LimitType_FIRST
#define _firestore_BundledQuery_LimitType_MAX firestore_BundledQuery_LimitType_LAST
#define _firestore_BundledQuery_LimitType_ARRAYSIZE ((firestore_BundledQuery_LimitType)(firestore_BundledQuery_LimitType_LAST+1))

/* Struct definitions */
typedef struct _firestore_BundleMetadata {
    pb_bytes_array_t *id;
    google_protobuf_Timestamp create_time;
    uint32_t version;
    uint32_t total_documents;
    uint64_t total_bytes;

    std::string ToString(int indent = 0) const;
/* @@protoc_insertion_point(struct:firestore_BundleMetadata) */
} firestore_BundleMetadata;

typedef struct _firestore_BundledDocumentMetadata {
    pb_bytes_array_t *name;
    google_protobuf_Timestamp read_time;
    bool exists;
    pb_size_t queries_count;
    pb_bytes_array_t **queries;

    std::string ToString(int indent = 0) const;
/* @@protoc_insertion_point(struct:firestore_BundledDocumentMetadata) */
} firestore_BundledDocumentMetadata;

typedef struct _firestore_BundledQuery {
    pb_bytes_array_t *parent;
    pb_size_t which_query_type;
    union {
        google_firestore_v1_StructuredQuery structured_query;
    };
    firestore_BundledQuery_LimitType limit_type;

    std::string ToString(int indent = 0) const;
/* @@protoc_insertion_point(struct:firestore_BundledQuery) */
} firestore_BundledQuery;

typedef struct _firestore_NamedQuery {
    pb_bytes_array_t *name;
    firestore_BundledQuery bundled_query;
    google_protobuf_Timestamp read_time;

    std::string ToString(int indent = 0) const;
/* @@protoc_insertion_point(struct:firestore_NamedQuery) */
} firestore_NamedQuery;

typedef struct _firestore_BundleElement {
    pb_size_t which_element_type;
    union {
        firestore_BundleMetadata metadata;
        firestore_NamedQuery named_query;
        firestore_BundledDocumentMetadata document_metadata;
        google_firestore_v1_Document document;
    };

    std::string ToString(int indent = 0) const;
/* @@protoc_insertion_point(struct:firestore_BundleElement) */
} firestore_BundleElement;

/* Default values for struct fields */

/* Initializer values for message structs */
#define firestore_BundledQuery_init_default      {NULL, 0, {google_firestore_v1_StructuredQuery_init_default}, _firestore_BundledQuery_LimitType_MIN}
#define firestore_NamedQuery_init_default        {NULL, firestore_BundledQuery_init_default, google_protobuf_Timestamp_init_default}
#define firestore_BundledDocumentMetadata_init_default {NULL, google_protobuf_Timestamp_init_default, 0, 0, NULL}
#define firestore_BundleMetadata_init_default    {NULL, google_protobuf_Timestamp_init_default, 0, 0, 0}
#define firestore_BundleElement_init_default     {0, {firestore_BundleMetadata_init_default}}
#define firestore_BundledQuery_init_zero         {NULL, 0, {google_firestore_v1_StructuredQuery_init_zero}, _firestore_BundledQuery_LimitType_MIN}
#define firestore_NamedQuery_init_zero           {NULL, firestore_BundledQuery_init_zero, google_protobuf_Timestamp_init_zero}
#define firestore_BundledDocumentMetadata_init_zero {NULL, google_protobuf_Timestamp_init_zero, 0, 0, NULL}
#define firestore_BundleMetadata_init_zero       {NULL, google_protobuf_Timestamp_init_zero, 0, 0, 0}
#define firestore_BundleElement_init_zero        {0, {firestore_BundleMetadata_init_zero}}

/* Field tags (for use in manual encoding/decoding) */
#define firestore_BundleMetadata_id_tag          1
#define firestore_BundleMetadata_create_time_tag 2
#define firestore_BundleMetadata_version_tag     3
#define firestore_BundleMetadata_total_documents_tag 4
#define firestore_BundleMetadata_total_bytes_tag 5
#define firestore_BundledDocumentMetadata_name_tag 1
#define firestore_BundledDocumentMetadata_read_time_tag 2
#define firestore_BundledDocumentMetadata_exists_tag 3
#define firestore_BundledDocumentMetadata_queries_tag 4
#define firestore_BundledQuery_structured_query_tag 2
#define firestore_BundledQuery_parent_tag        1
#define firestore_BundledQuery_limit_type_tag    3
#define firestore_NamedQuery_name_tag            1
#define firestore_NamedQuery_bundled_query_tag   2
#define firestore_NamedQuery_read_time_tag       3
#define firestore_BundleElement_metadata_tag     1
#define firestore_BundleElement_named_query_tag  2
#define firestore_BundleElement_document_metadata_tag 3
#define firestore_BundleElement_document_tag     4

/* Struct field encoding specification for nanopb */
extern const pb_field_t firestore_BundledQuery_fields[4];
extern const pb_field_t firestore_NamedQuery_fields[4];
extern const pb_field_t firestore_BundledDocumentMetadata_fields[5];
extern const pb_field_t firestore_BundleMetadata_fields[6];
extern const pb_field_t firestore_BundleElement_fields[5];

/* Maximum encoded size of messages (where known) */
/* firestore_BundledQuery_size depends on runtime parameters */
/* firestore_NamedQuery_size depends on runtime parameters */
/* firestore_BundledDocumentMetadata_size depends on runtime parameters */
/* firestore_BundleMetadata_size depends on runtime parameters */
/* firestore_BundleElement_size depends on runtime parameters */

/* Message IDs (where set with "msgid" option) */
#ifdef PB_MSGID

#define BUNDLE_MESSAGES \


#endif

const char* EnumToString(firestore_BundledQuery_LimitType value);
}  // namespace firestore
}  // namespace firebase

/* @@protoc_insertion_point(eof) */

#endif
