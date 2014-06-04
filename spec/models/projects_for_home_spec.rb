require 'spec_helper'

describe ProjectsForHome do
  include ActiveSupport::Testing::TimeHelpers

  describe '.featured' do
    subject { ProjectsForHome.featured }

    let(:featured) do
      create(:project,
             featured: true,
             state: 'online')
    end

    it 'should return featured project' do
      featured
      expect(subject).to eq [featured]
    end

    it 'should return a project object' do
      featured
      expect(subject.first).to be_instance_of(Project)
    end
  end

  describe '.recommends' do
    subject { ProjectsForHome.recommends }

    let(:not_recommended) do
      create(:project,
             recommended: false,
             state: 'online',
             home_page: true)
    end

    let(:not_home_page) do
      create(:project,
             recommended: true,
             state: 'online',
             home_page: false)
    end

    it 'should return only 5 recommended projects' do
      6.times do
        create(:project,
               recommended: true,
               state: 'online',
               home_page: true)
      end

      expect(subject.size).to eq 5
    end

    it 'should return a project object' do
      create(:project,
             recommended: true,
             state: 'online',
             home_page: true)

      expect(subject.first).to be_instance_of(Project)
    end

    it 'should not include not recommended project' do
      not_recommended
      expect(subject).not_to include(not_recommended)
    end

    it 'should not include not home page project' do
      not_home_page
      expect(subject).not_to include(not_home_page)
    end
  end

  describe '.expiring' do
    subject { ProjectsForHome.expiring }

    let(:recommended) do
      create(:project,
             recommended: true,
             state: 'online',
             home_page: true)
    end

    let(:not_expiring) do
      create(:project,
             recommended: false,
             state: 'online',
             online_days: 50,
             online_date: 2.days.ago)
    end

    let(:not_home_page) do
      create(:project,
             recommended: false,
             state: 'online',
             online_days: 10,
             online_date: 6.days.ago,
             home_page: false)
    end

    it 'should return only 4 expiring projects' do
      5.times do
        create(:project,
               recommended: false,
               state: 'online',
               online_days: 10,
               online_date: 6.days.ago,
               home_page: true)
      end
      expect(subject.size).to eq 4
    end

    it 'should return a project object' do
      create(:project,
             recommended: false,
             state: 'online',
             online_days: 10,
             online_date: 6.days.ago,
             home_page: true)

      expect(subject.first).to be_instance_of(Project)
    end

    it 'should not include not expiring project' do
      not_expiring
      expect(subject).not_to include(not_expiring)
    end

    it 'show not include recommended project' do
      recommended
      expect(subject).not_to include(recommended)
    end

    it 'should not include not home page project' do
      not_home_page
      expect(subject).not_to include(not_home_page)
    end
  end

  describe '.soon' do
    subject { ProjectsForHome.soon }

    let(:not_soon) do
      create(:project,
             state: 'online',
             uploaded_image: File.open("#{Rails.root}/spec/fixtures/image.png"),
             home_page: true)
    end

    let(:not_home_page) do
      create(:project,
             state: 'soon',
             uploaded_image: File.open("#{Rails.root}/spec/fixtures/image.png"),
             home_page: false)
    end

    let(:without_image) do
      create(:project,
             state: 'soon',
             home_page: true)
    end

    it 'should return only 4 soon projects' do
      5.times do
        create(:project,
               state: 'soon',
               uploaded_image: File.open("#{Rails.root}/spec/fixtures/image.png"),
               home_page: true)
      end
      expect(subject.size).to eq 4
    end

    it 'should return a project object' do
      create(:project,
             state: 'soon',
             uploaded_image: File.open("#{Rails.root}/spec/fixtures/image.png"),
             home_page: true)

      expect(subject.first).to be_instance_of(Project)
    end

    it 'should not include not soon project' do
      not_soon
      expect(subject).not_to include(not_soon)
    end

    it 'should not include not home page project' do
      not_home_page
      expect(subject).not_to include(not_home_page)
    end

    it 'should not include projects without images' do
      not_home_page
      expect(subject).not_to include(without_image)
    end
  end

  describe '.successful' do
    subject { ProjectsForHome.successful }

    let(:not_successful) do
      create(:project,
             state: 'online',
             home_page: true)
    end

    let(:not_home_page) do
      create(:project,
             state: 'successful',
             home_page: false)
    end

    it 'should return only 4 soon projects' do
      5.times do
        create(:project,
               state: 'successful',
               home_page: true)
      end
      expect(subject.size).to eq 4
    end

    it 'should return a project object' do
      create(:project,
             state: 'successful',
             home_page: true)

      expect(subject.first).to be_instance_of(Project)
    end

    it 'should not include not successful project' do
      not_successful
      expect(subject).not_to include(not_successful)
    end

    it 'should not include not home page project' do
      not_home_page
      expect(subject).not_to include(not_home_page)
    end
  end

  describe '.with_active_matches' do
    subject { ProjectsForHome.with_active_matches }

    let(:with_match_active) { create(:match).project }

    let(:without_match_active) do
      travel_to(10.days.ago) do
        create(:match, starts_at: 5.days.from_now, finishes_at: 7.days.from_now).project
      end
    end

    it 'should limit in 4 projects' do
      create_list(:match, 5)

      expect(ProjectsForHome.with_active_matches).to have(4).items
    end

    it 'should return Project instances' do
      with_match_active

      expect(subject.first).to be_instance_of(Project)
    end

    it 'should include projects with active matches' do
      with_match_active

      expect(subject).to include(with_match_active)
    end

    it 'should not include projects without active matches' do
      without_match_active

      expect(subject).not_to include(without_match_active)
    end
  end
end
