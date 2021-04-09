require 'rails_helper'

RSpec.describe User, type: :model do
  describe User do
    let(:user) { build(:user) }

    # nameのvalidationテスト

    describe 'name validation' do
      # nameが存在する場合は有効であること
      context 'when present' do
        it 'is valid ' do
          user.name = 'Test'
          expect(user).to be_valid
        end
      end
      # nameが空の場合は無効であること

      context 'when name is nil' do
        it 'is invalid' do
          user.name = nil
          expect(user).to be_invalid
          expect(user.errors.full_messages).to include('名前を入力してください')
        end
      end
      # nameが50文字以下の場合は有効であること

      context 'when length is 50 characters or less' do
        it 'is valid' do
          user.name = 'a' * 50
          expect(user).to be_valid
        end
      end
      # nameが50文字より長い場合は無効であること

      context 'when length is more than 50 characters' do
        it 'is invalid' do
          user.name = 'a' * 51
          expect(user).to be_invalid
          expect(user.errors.full_messages).to include('名前は50文字以内で入力してください')
        end
      end
    end

    # user_nameのvalidationテスト
    describe 'user_name validation' do
      # user_nameが存在する場合は有効であること
      context 'when present' do
        it 'is valid ' do
          user.user_name = 'user_name'
          expect(user).to be_valid
        end
      end
      # user_nameが空の場合は無効であること

      context 'when user_name is nil' do
        it 'is invalid' do
          user.user_name = nil
          user.valid?
          expect(user.errors.full_messages).to include('ユーザーネームを入力してください')
        end
      end

      # user_nameが50文字以下の場合は有効であること

      context 'when length is 50 characters or less' do
        it 'is valid' do
          user.user_name = 'a' * 50
          expect(user).to be_valid
        end
      end
      # user_nameが50文字より長い場合は無効であること

      context 'when length is more than 50 characters' do
        it 'is invalid' do
          user.user_name = 'a' * 51
          user.valid?
          expect(user.errors.full_messages).to include('ユーザーネームは50文字以内で入力してください')
        end
      end

      # user_nameが７文字以上の場合は有効であること

      context 'when length is 7 characters or less' do
        it 'is valid' do
          user.user_name = 'a' * 7
          expect(user).to be_valid
        end
      end
      # user_nameが7文字より短い場合は無効であること

      context 'when length is less than 7 characters' do
        it 'is invalid' do
          user.user_name = 'a' * 6
          user.valid?
          expect(user.errors.full_messages).to include('ユーザーネームは7文字以上で入力してください')
        end
      end

      # 同一のuser_nameが既に登録されている場合は、無効であること

      context 'when already taken' do
        it 'is invalid' do
          FactoryBot.create(:other_user, user_name: 'user_name')
          user.user_name = 'user_name'
          user.valid?
          expect(user.errors.full_messages).to include('ユーザーネームはすでに存在します')
        end
      end
    end
    # user_nameの大文字と小文字を区別せず、一意ではない場合は、無効であること

    context 'when case insensitive and not unipue' do
      it 'is invalid' do
        FactoryBot.create(:other_user, user_name: 'user_name')
        user.user_name = 'USER_NAME'
        user.valid?
        expect(user.errors.full_messages).to include('ユーザーネームはすでに存在します')
      end
    end

    # user_nameの形式が正しい場合は、有効であること

    context 'when correct format' do
      ok_user_names = %w[
        user__name
        ________
        ____name
        user...name
        us.er.na.me
        1234567
        USERNAME
      ]
      it 'is valid' do
        ok_user_names.each do |user_name|
          user.user_name = user_name
          expect(user).to be_valid
        end
      end
    end
    # user_nameの形式が正しくない場合は、無効であること

    context 'when incorrect format' do
      ng_user_names = %w[
        user/name
        user-name
        |~=?+"a"
        １２３４５６７８
        ＡＢＣＤＥＦＧＨ
        username@
        ...username
        username...
      ]
      it 'is invalid' do
        ng_user_names.each do |user_name|
          user.user_name = user_name
          user.valid?
          expect(user.errors.full_messages).to include('ユーザーネームは半角英数字•ﾋﾟﾘｵﾄﾞ•ｱﾝﾀﾞｰﾊﾞｰが使えます')
        end
      end
    end
    # emailのvalidationテスト

    describe 'email validation' do
      # emailが存在する場合は有効であること
      context 'when email is present' do
        it 'is valid' do
          user.email = 'test@example.com'
          expect(user).to be_valid
        end
      end
      # emailが空の場合は無効であること

      context 'when email is nil' do
        it 'is invalid' do
          user.email = nil
          expect(user).to be_invalid
          expect(user.errors.full_messages).to include('メールアドレスを入力してください')
        end
      end
      # emailが255文字以下の場合は有効であること

      context 'when length is 255 characters or less' do
        it 'is valid' do
          user.email = "#{'a' * 243}@example.com"
          expect(user).to be_valid
        end
      end
      # emailが255文字より長い場合は、無効であること

      context 'when length is more than 255 characters' do
        it 'is invalid' do
          user.email = "#{'a' * 244}@example.com"
          expect(user).to be_invalid
          expect(user.errors.full_messages).to include('メールアドレスは255文字以内で入力してください')
        end
      end
      # emailの形式が正しい場合は、有効であること

      context 'when correct format' do
        ok_emails = %w[
          A@EX.COM
          a-_@e-x.c-o_m.j_p
          a.a@ex.com
          a@e.co.js
          1.1@ex.com
          a.a+a@ex.com
        ]
        it 'is valid' do
          ok_emails.each do |email|
            user.email = email
            expect(user).to be_valid
          end
        end
      end
      # emailの形式が正しくない場合は、無効であること

      context 'when is incorrect format' do
        ng_emails = %w[
          aaa
          a.ex.com
          メール@ex.com
          a~a@ex.com
          a@|.com
          a@ex.
          .a@ex.com
          a＠ex.com
          Ａ@ex.com
          a@?,com
          １@ex.com
          "a"@ex.com
          a@ex@co.jp
        ]
        it 'is invalid' do
          ng_emails.each do |email|
            user.email = email
            expect(user).to be_invalid
            expect(user.errors.full_messages).to include('メールアドレスは不正な値です')
          end
        end
      end
      # emailが小文字で保存されていること

      it 'is saved in lowercase' do
        user.email = 'TEST@EXAMPLE.COM'
        user.save
        expect(user.reload.email).to eq 'test@example.com'
      end
    end

    describe 'activated validation' do
      # アクティブユーザーがいない場合、同一のemailが登録できていること

      context 'when activated false' do
        it 'allow same email' do
          FactoryBot.create(:user, email: 'test@example.com', activated: false)
          other_user = FactoryBot.build(:other_user, email: 'test@example.com')
          other_user.save
          expect(other_user).to be_valid
        end
      end

      # 同一のemailでユーザーがアクティブの場合、無効であること

      context 'when activated true' do
        before do
          FactoryBot.create(:user, email: 'test@example.com', activated: true)
        end

        it 'is invalid and already taken' do
          other_user = FactoryBot.build(:other_user, email: 'test@example.com')
          other_user.save
          expect(other_user).to be_invalid
          expect(other_user.errors.full_messages).to include('メールアドレスはすでに存在します')
        end
      end
    end

    describe 'password validation' do
      # passwordが存在する場合、有効であること
      context 'when present' do
        it 'is valid' do
          user.password = 'password'
          expect(user).to be_valid
        end
      end
      # passwordが空の場合は無効であること

      context 'when password is nil' do
        it 'is invalid' do
          user = build(:user, password: nil)
          expect(user).to be_invalid
          expect(user.errors.full_messages).to include('パスワードを入力してください')
        end
      end
      # passwordが8文字より短い場合は無効であること

      context 'when length is 8 characters' do
        it 'is valid' do
          user.password = user.password_confirmation = 'a' * 8
          expect(user).to be_valid
        end

        it 'is invalid' do
          user.password = user.password_confirmation = 'a' * 7
          expect(user).to be_invalid
          expect(user.errors.full_messages).to include('パスワードは8文字以上で入力してください')
        end
      end
      # passwordが72文字より長い場合無効であること

      context 'when length is 72 characters' do
        it 'is valid' do
          user.password = user.password_confirmation = 'a' * 72
          expect(user).to be_valid
        end

        it 'is invalid' do
          user.password = user.password_confirmation = 'a' * 73
          expect(user).to be_invalid
          expect(user.errors.full_messages).to include('パスワードは72文字以内で入力してください')
        end
      end
      # passwordの形式が正しい場合は、有効であること

      context 'when correct format' do
        ok_passwords = %w[
          pass---word
          ________
          12341234
          ____pass
          pass----
          PASSWORD
        ]
        it 'is valid' do
          ok_passwords.each do |pass|
            user.password = user.password_confirmation = pass
            expect(user).to be_valid
          end
        end
      end
      # passwordの形式が正しくない場合は、無効であること

      context 'when is incorrect format' do
        ng_passwords = %w[
          pass/word
          pass.word
          |~=?+"a"
          １２３４５６７８
          ＡＢＣＤＥＦＧＨ
          password@
        ]
        it 'is invalid' do
          ng_passwords.each do |pass|
            user.password = user.password_confirmation = pass
            expect(user).to be_invalid
            expect(user.errors.full_messages).to include('パスワードは半角英数字•ﾊｲﾌﾝ•ｱﾝﾀﾞｰﾊﾞｰが使えます')
          end
        end
      end
    end
    #　userモデルの関連付けのテスト

    describe 'associated eventposts relationship like' do
      let(:user) { create(:user) }
      let(:other_user) { create(:other_user) }
      let(:eventpost) { create(:eventpost, user: user) }

      before do
        user.follow(other_user)
        user.likes.create(eventpost_id: eventpost.id)
      end

      # 　ユーザーが削除されるとイベントも削除されること。
      it 'dependent destroy eventposts' do
        expect do
          user.destroy
        end.to change(Eventpost, :count).by(-1)
      end

      # 　ユーザーが削除されるとフォロー解除されていること。
      it 'dependent destroy follow' do
        user.destroy
        expect(other_user.followers).not_to include(user)
      end

      # 　other_userが削除されるとフォロー解除されていること。
      it 'dependent destroy follower' do
        other_user.destroy
        expect(user).not_to be_following(other_user)
      end

      #　ユーザーが削除されるといいねが削除されること
      it 'dependent destroy like' do
        expect do
          user.destroy
        end.to change(Like, :count).by(-1)
      end
    end

    # 　フォローメソッドのテスト

    describe 'follow and unfollow' do
      let(:user) { create(:user) }
      let(:other_user) { create(:other_user) }
      # 　何もしていない状態でフォローしていないこと

      it 'not following other_user' do
        expect(user).not_to be_following(other_user)
      end

      context 'when user follow and unfollw other_user' do
        before do
          user.follow(other_user)
        end
        # 　フォローした時フォローしていること

        it 'following other_user' do
          expect(user).to be_following(other_user)
        end
        # 　フォロワーに含まれていること

        it 'include user to other_user followers' do
          expect(other_user.followers).to include(user)
        end
        # 　フォロー解除した時フォローしていないこと

        it 'not following other_user' do
          user.unfollow(other_user)
          expect(user).not_to be_following(other_user)
        end
      end
    end

    describe 'feed test' do
      let(:user) { create(:user) }
      let(:other_user) { create(:other_user) }
      let(:michael) { create(:michael) }

      context 'when user followed other_user not followed michael' do
        before do
          user.follow(other_user)
        end
        # other_userのイベントを含んでいること

        it 'feed includes other_user_event' do
          other_user.eventposts.each do |event_following|
            expect(user.feed).to include event_following
          end
        end
        # 　userのイベントを含んでいること

        it 'feed includes user_event' do
          user.eventposts.each do |event_self|
            expect(user.feed).to include event_self
          end
        end
        # 　michaelのイベントを含んでいないこと

        it 'feed not include michael_event' do
          michael.eventposts.each do |event_unfollowed|
            expect(user.feed).not_to include event_unfollowed
          end
        end
      end
    end
  end
end
