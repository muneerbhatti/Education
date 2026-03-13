# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


User.find_or_create_by!(email: 'aba@kaleidoscopekollege.com') do |user|
  user.first_name = 'Corie'
  user.last_name = ' '
  user.password = '123456'
end

WebsiteDetail.find_or_create_by!(email: 'aba@kaleidoscopekollege.com') do |company|
  company.name = 'Kaleidoscope Kollege'
  company.phone_1 = '(443) 822-4357'
  company.phone_2 = '(703) 718-6085'
  company.address_1 = 'your address'
  company.instagram = 'https://www.instagram.com/kaleidoscopekollege'
  company.facebook = 'https://www.facebook.com/Kaleidoscopekollege'
  company.about = 'Providing comprehensive ABA therapy and specialized support services to help individuals reach their full potential in life, learning, and community through evidence-based behavioral strategies combined with compassionate care.'
end


puts "Seeding Services & Courses..."

services_data = [
  {
    title: "Speech & Language Therapy Services",
    description: "Professional speech and language therapy services to support communication development.",
    image: 'c-1.png',
    courses: [
      {
        title: "Speech Sound Disorders",
        category: "Speech & Language Therapy",
        difficulty: "Beginner – Intermediate",
        videos_count: 28,
        duration_weeks: 6,
        total_hours: 5,
        assignments: "Weekly Practice Activities",
        price: 40,
        description: "Learn assessment and therapy techniques for articulation and phonological disorders.",
        image: 'ai2.png',
        instructor: {
          name: "Dr. Sarah Johnson",
          email: "sarah.johnson@example.com",
          designation: "Senior Speech Therapist",
          profile_description: "10+ years of experience in pediatric speech and language therapy.",
          rating: 4.8,
          specialist: "Speech Sound Disorders",
          image: 'Card.png'
        }
      },
      {
        title: "Language Development & Disorders",
        category: "Speech & Language Therapy",
        difficulty: "Intermediate",
        videos_count: 35,
        duration_weeks: 8,
        total_hours: 6,
        assignments: "Weekly Assignments",
        price: 55,
        description: "Understand receptive and expressive language disorders with practical intervention strategies.",
        image: 'ps.png',
        instructor: {
          name: "Dr. Sarah Johnson",
          email: "sarah.johnson@example.com",
          designation: "Senior Speech Therapist",
          profile_description: "10+ years of experience in pediatric speech and language therapy.",
          rating: 4.8,
          specialist: "Speech Sound Disorders",
          image: 'Card.png'
        }

      }
    ]
  },

  {
    title: "Occupational Therapy Services",
    description: "Occupational therapy programs focused on functional independence and daily living skills.",
    image: 'c-1.png',
    courses: [
      {
        title: "Fine Motor Skills Development",
        category: "Occupational Therapy",
        difficulty: "Beginner",
        videos_count: 30,
        duration_weeks: 6,
        total_hours: 5,
        assignments: "Weekly Skill Activities",
        price: 45,
        description: "Improve hand coordination, grip strength, and fine motor control.",
        image: 'ai.png',
        instructor: {
          name: "Dr. Sarah Johnson",
          email: "sarah.johnson@example.com",
          designation: "Senior Speech Therapist",
          profile_description: "10+ years of experience in pediatric speech and language therapy.",
          rating: 4.8,
          specialist: "Speech Sound Disorders",
          image: 'Card-2.png'
        }
      },
      {
        title: "Sensory Processing & Integration",
        category: "Occupational Therapy",
        difficulty: "Intermediate",
        videos_count: 40,
        duration_weeks: 8,
        total_hours: 7,
        assignments: "Sensory Plans & Reports",
        price: 60,
        description: "Understand sensory systems and apply integration strategies at home and school.",
        image: 'ai3.png',
        instructor: {
          name: "Dr. Sarah Johnson",
          email: "sarah.johnson@example.com",
          designation: "Senior Speech Therapist",
          profile_description: "10+ years of experience in pediatric speech and language therapy.",
          rating: 4.8,
          specialist: "Speech Sound Disorders",
          image: 'Card-3.png'
        }
      }
    ]
  },

  {
    title: "Physical Therapy Services",
    description: "Physical therapy programs to enhance strength, posture, and functional movement.",
    image: 'c-4.png',
    courses: [
      {
        title: "Gross Motor Skills Development",
        category: "Physical Therapy",
        difficulty: "Beginner – Intermediate",
        videos_count: 32,
        duration_weeks: 6,
        total_hours: 6,
        assignments: "Weekly Exercise Plans",
        price: 45,
        description: "Develop balance, coordination, and movement through guided exercises.",
        image: 'ai2.png',
        instructor: {
          name: "Dr. Sarah Johnson",
          email: "sarah.johnson@example.com",
          designation: "Senior Speech Therapist",
          profile_description: "10+ years of experience in pediatric speech and language therapy.",
          rating: 4.8,
          specialist: "Speech Sound Disorders",
          image: 'Card-3.png'
        }
      }
    ]
  },

  {
    title: "Psychological Services",
    description: "Psychological and behavioral support services for emotional well-being.",
    image: 'c-3.png',
    courses: [
      {
        title: "Emotional & Behavioral Regulation",
        category: "Psychological Services",
        difficulty: "Beginner – Intermediate",
        videos_count: 34,
        duration_weeks: 7,
        total_hours: 6,
        assignments: "Weekly Reflection Tasks",
        price: 50,
        description: "Learn emotional regulation techniques and behavioral coping strategies.",
        image: 'ai3.png',
        instructor: {
          name: "Dr. Sarah Johnson",
          email: "sarah.johnson@example.com",
          designation: "Senior Speech Therapist",
          profile_description: "10+ years of experience in pediatric speech and language therapy.",
          rating: 4.8,
          specialist: "Speech Sound Disorders",
          image: 'Card-3.png'
        }
      }
    ]
  },

  {
    title: "ABA Therapy Services",
    description: "Applied Behavior Analysis therapy programs for skill development and behavior support.",
    image: 'c-5.png',
    courses: [
      {
        title: "Introduction to ABA Therapy",
        category: "ABA Therapy",
        difficulty: "Beginner",
        videos_count: 30,
        duration_weeks: 6,
        total_hours: 5,
        assignments: "Behavior Tracking Sheets",
        price: 45,
        description: "Foundational principles and ethical practices of ABA therapy.",
        image: 'ai2.png',
        instructor: {
          name: "Dr. Sarah Johnson",
          email: "sarah.johnson@example.com",
          designation: "Senior Speech Therapist",
          profile_description: "10+ years of experience in pediatric speech and language therapy.",
          rating: 4.8,
          specialist: "Speech Sound Disorders",
          image: 'Card-3.png'
        }
      }
    ]
  },

  {
    title: "Bilingual & Virtual Therapy Services",
    description: "Language and therapy services delivered bilingually and through virtual platforms.",
    image: 'c-6.png',
    courses: [
      {
        title: "Bilingual Speech & Language Development",
        category: "Bilingual Therapy",
        difficulty: "Intermediate",
        videos_count: 33,
        duration_weeks: 7,
        total_hours: 6,
        assignments: "Language Practice Activities",
        price: 50,
        description: "Support multilingual language development using evidence-based strategies.",
        image: 'ai2.png',
        instructor: {
          name: "Dr. Sarah Johnson",
          email: "sarah.johnson@example.com",
          designation: "Senior Speech Therapist",
          profile_description: "10+ years of experience in pediatric speech and language therapy.",
          rating: 4.8,
          specialist: "Speech Sound Disorders",
          image: 'Card-3.png'
        }
      },
      {
        title: "Virtual Therapy Essentials",
        category: "Virtual Therapy",
        difficulty: "Beginner",
        videos_count: 26,
        duration_weeks: 5,
        total_hours: 4,
        assignments: "Online Session Practice",
        price: 35,
        description: "Learn best practices for delivering effective teletherapy sessions.",
        image: 'ai3.png',
        instructor: {
          name: "Dr. Sarah Johnson",
          email: "sarah.johnson@example.com",
          designation: "Senior Speech Therapist",
          profile_description: "10+ years of experience in pediatric speech and language therapy.",
          rating: 4.8,
          specialist: "Speech Sound Disorders",
          image: 'Card-3.png'
        }
      }
    ]
  }
]

puts "Seeding Services, Courses & Instructors..."

services_data.each do |service_data|
  service = Service.find_or_create_by!(title: service_data[:title]) do |s|
    s.description = service_data[:description]
  end
  image_path = Rails.root.join("app/assets/images/#{service_data[:image]}")
  if File.exist?(image_path)
    service.image.attach(
      io: File.open(image_path),
      filename: service_data[:image],
      content_type: Marcel::MimeType.for(Pathname.new(image_path))
    )
  end

  service_data[:courses].each do |course_data|
    course = Course.find_or_create_by!(
      title: course_data[:title],
      service: service
    ) do |c|
      c.category = course_data[:category]
      c.difficulty = course_data[:difficulty]
      c.videos_count = course_data[:videos_count]
      c.duration_weeks = course_data[:duration_weeks]
      c.total_hours = course_data[:total_hours]
      c.assignments = course_data[:assignments]
      c.price = course_data[:price]
      c.description = course_data[:description]
    end
    image_path = Rails.root.join("app/assets/images/#{course_data[:image]}")
    if File.exist?(image_path)
      course.image.attach(
        io: File.open(image_path),
        filename: course_data[:image],
        content_type: Marcel::MimeType.for(Pathname.new(image_path))
      )
    end

    # Create Instructor (one per course)
    if course_data[:instructor]
      instructor = Instructor.find_or_create_by!(
        email: course_data[:instructor][:email],
        course: course
      ) do |i|
        i.name = course_data[:instructor][:name]
        i.designation = course_data[:instructor][:designation]
        i.profile_description = course_data[:instructor][:profile_description]
        i.rating = course_data[:instructor][:rating]
        i.specialist = course_data[:instructor][:specialist]
      end
      image_path = Rails.root.join("app/assets/images/#{course_data[:instructor][:image]}")
      if File.exist?(image_path)
        instructor.image.attach(
          io: File.open(image_path),
          filename: course_data[:instructor][:image],
          content_type: Marcel::MimeType.for(Pathname.new(image_path))
        )
      end
    end
  end
end

puts "✅ Services, Courses & Instructors seeded successfully!"
