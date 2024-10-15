# frozen_string_literal: true

json.array! @uploads, partial: 'upload/parse', as: :post
